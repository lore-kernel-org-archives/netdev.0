From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] netfilter: nft_counter: rework atomic dump and
 reset
Date: Sun, 11 Dec 2016 11:41:17 +0100
Message-ID: <20161211104117.GA2521@salvia>
References: <1481378741-19871-1-git-send-email-pablo@netfilter.org>
 <20161210141655.GA19963@salvia>
 <20161210142501.GA25221@salvia>
 <1481384408.4930.210.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, arnd@arndb.de,
        netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56770 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753132AbcLKKlb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 11 Dec 2016 05:41:31 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 68786BA70B
        for <netdev@vger.kernel.org>; Sun, 11 Dec 2016 11:41:25 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 5B54CDA80C
        for <netdev@vger.kernel.org>; Sun, 11 Dec 2016 11:41:25 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 7E028DA808
        for <netdev@vger.kernel.org>; Sun, 11 Dec 2016 11:41:22 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <1481384408.4930.210.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 10, 2016 at 07:40:08AM -0800, Eric Dumazet wrote:
> On Sat, 2016-12-10 at 15:25 +0100, Pablo Neira Ayuso wrote:
> > On Sat, Dec 10, 2016 at 03:16:55PM +0100, Pablo Neira Ayuso wrote:
> =
> >  
> > -       nft_counter_fetch(priv, &total, reset);
> > +       nft_counter_fetch(priv, &total);
> > +       if (reset)
> > +               nft_counter_reset(priv, &total);
> >  
> >         if (nla_put_be64(skb, NFTA_COUNTER_BYTES,
> > cpu_to_be64(total.bytes),
> >                          NFTA_COUNTER_PAD) ||
> 
> Night be nitpicking, but you might reset the stats only if the
> nla_put_be64() succeeded.

Right, I've fixed this in the v2.

> But regardless of this detail, patch looks good and is very close to the
> one I cooked and was about to send this morning.

Thanks a lot!
