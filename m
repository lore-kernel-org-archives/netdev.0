From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mpls: Fix nexthop alive tracking on down events
Date: Thu, 16 Mar 2017 20:24:30 -0700 (PDT)
Message-ID: <20170316.202430.690844334346178771.davem@davemloft.net>
References: <1489448950-13340-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        rshearma@brocade.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53606 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752690AbdCQDYb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 23:24:31 -0400
In-Reply-To: <1489448950-13340-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon, 13 Mar 2017 16:49:10 -0700

> Alive tracking of nexthops can account for a link twice if the carrier
> goes down followed by an admin down of the same link rendering multipath
> routes useless. This is similar to 79099aab38c8 for UNREGISTER events and
> DOWN events.
> 
> Fix by tracking number of alive nexthops in mpls_ifdown similar to the
> logic in mpls_ifup. Checking the flags per nexthop once after all events
> have been processed is simpler than trying to maintian a running count
> through all event combinations.
> 
> Also, WRITE_ONCE is used instead of ACCESS_ONCE to set rt_nhn_alive
> per a comment from checkpatch:
>     WARNING: Prefer WRITE_ONCE(<FOO>, <BAR>) over ACCESS_ONCE(<FOO>) = <BAR>
> 
> Fixes: c89359a42e2a4 ("mpls: support for dead routes")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied.
