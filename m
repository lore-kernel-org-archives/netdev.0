From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] s390/qeth: fix L3 next-hop in xmit qeth hdr
Date: Mon, 07 Aug 2017 11:25:30 -0700 (PDT)
Message-ID: <20170807.112530.1647977400606242335.davem@davemloft.net>
References: <20170807112839.91254-1-ubraun@linux.vnet.ibm.com>
        <20170807112839.91254-2-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33452 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751505AbdHGSZb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 14:25:31 -0400
In-Reply-To: <20170807112839.91254-2-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Mon,  7 Aug 2017 13:28:39 +0200

> From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
> 
> On L3, the qeth_hdr struct needs to be filled with the next-hop
> IP address.
> The current code accesses rtable->rt_gateway without checking that
> rtable is a valid address. The accidental access to a lowcore area
> results in a random next-hop address in the qeth_hdr.
> rtable (or more precisely, skb_dst(skb)) can be NULL in rare cases
> (for instance together with AF_PACKET sockets).
> This patch adds the missing NULL-ptr checks.
> 
> Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
> Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
> Fixes: 87e7597b5a3 qeth: Move away from using neighbour entries in qeth_l3_fill_header()

Applied.
