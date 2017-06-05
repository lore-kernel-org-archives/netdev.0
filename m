From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V5 net-next] neigh: Really delete an arp/neigh entry on
 "ip neigh delete" or "arp -d"
Date: Sun, 04 Jun 2017 21:37:33 -0400 (EDT)
Message-ID: <20170604.213733.1423109980903333523.davem@davemloft.net>
References: <1496419309-91478-1-git-send-email-sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org, ja@ssi.bg
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54244 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751193AbdFEBhf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 21:37:35 -0400
In-Reply-To: <1496419309-91478-1-git-send-email-sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Fri,  2 Jun 2017 09:01:49 -0700

> The command
>   # arp -s 62.2.0.1 a:b:c:d:e:f dev eth2
> adds an entry like the following (listed by "arp -an")
>   ? (62.2.0.1) at 0a:0b:0c:0d:0e:0f [ether] PERM on eth2
> but the symmetric deletion command
>   # arp -i eth2 -d 62.2.0.1
> does not remove the PERM entry from the table, and instead leaves behind
>   ? (62.2.0.1) at <incomplete> on eth2
> 
> The reason is that there is a refcnt of 1 for the arp_tbl itself
> (neigh_alloc starts off the entry with a refcnt of 1), thus
> the neigh_release() call from arp_invalidate() will (at best) just
> decrement the ref to 1, but will never actually free it from the
> table.
> 
> To fix this, we need to do something like neigh_forced_gc: if
> the refcnt is 1 (i.e., on the table's ref), remove the entry from
> the table and free it. This patch refactors and shares common code
> between neigh_forced_gc and the newly added neigh_remove_one.
> 
> A similar issue exists for IPv6 Neighbor Cache entries, and is fixed
> in a similar manner by this patch.
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Reviewed-by: Julian Anastasov <ja@ssi.bg>

Applied, thank you.
