From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] neigh: initialize neigh entry correctly during
 arp processing
Date: Fri, 18 Aug 2017 16:10:11 -0700 (PDT)
Message-ID: <20170818.161011.1703904478516944881.davem@davemloft.net>
References: <20170817000251.38469-1-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, idosch@mellanox.com,
        ishkamiel@gmail.com, keescook@chromium.org,
        elena.reshetova@intel.com, sowmini.varadhan@oracle.com,
        fw@strlen.de, roopa@cumulusnetworks.com, ihrachys@redhat.com,
        dsa@cumulusnetworks.com, zhangshengju@cmss.chinamobile.com,
        maheshb@google.com
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34622 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750988AbdHRXKN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 19:10:13 -0400
In-Reply-To: <20170817000251.38469-1-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Wed, 16 Aug 2017 17:02:51 -0700

> From: Mahesh Bandewar <maheshb@google.com>
> 
> If the ARP processing creates a neigh entry, it's immediately marked
> as STALE without timer and stays that way in that state as long as
> host do not send traffic to that neighbour.
> 
> I observed this on hosts which are in IPv6 environment, where there is
> very little to no IPv4 traffic and neigh-entries are stuck in STALE
> mode. Ideally, the host should have PROBEd these neighbours before it
> can send the first packet out.
> 
> It happens as a result of following call sequence in an environment
> where host is mostly quiet as far as IPv4 traffic but few connected
> hosts/gateways are sending ARPs.
> 
>    arp_process()
>      neigh_event_ns()
>        neigh_lookup()
>          neigh_create()
>            neigh_alloc()
>              nud_state=NUD_NONE
>      neigh_update(nud_state=NUD_STALE)
> 
> In the above scenario, the neighbour entry does not get a chance to get
> PROBEd as subsequent call to neigh_update() marks  this entry STALE.
> This patch initializes the neigh-entry correctly if it was created as a
> result of neigh_lookup instead of just updating it in neigh_event_ns()
> right after creating it.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Please provide, in the commit message, a list of events including an
example packet exchange and timers firing which explains how this
situation arises.

Thank you.
