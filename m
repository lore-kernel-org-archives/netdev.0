From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Kernel problem
Date: Fri, 27 Feb 2009 09:29:12 +0000
Message-ID: <20090227092912.GC4156@ff.dom.local>
References: <20090227084109.GA4156@ff.dom.local> <20090227.005907.94994126.davem@davemloft.net> <20090227091216.GB4156@ff.dom.local> <20090227.011615.104197338.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, ash@sevsky.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f178.google.com ([209.85.218.178]:60339 "EHLO
	mail-bw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756890AbZB0J3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 04:29:21 -0500
Received: by bwz26 with SMTP id 26so926398bwz.37
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2009 01:29:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20090227.011615.104197338.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2009 at 01:16:15AM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Fri, 27 Feb 2009 09:12:16 +0000
...
> > netif_nit_deliver() is a place called by vlan with orig skb->dev, so
> > it could be reused to check for netpoll btw. Of course, return value
> > should be added etc. and maybe name changed too. It could be
> > something like this:
> 
> Note there is already a function that could do this and which needs to
> hit all the same RX entrypoints just like this check would.
> 
> And that is skb_bond_should_drop().
> 
> We could rename that to skb_rx_should_drop() and put the netpoll
> checks there.
> 
> There is some weird conditinalization of skb_bond_should_drop()'s call
> in netif_receive_skb() but that should be easy to change to suit our
> needs.  Perhaps by putting the calculation of the netdevice bonding
> pointers into that function.

Yes, it would be nice to have it in this one place, but I guess
currently for vlans we depend on vlan_hwaccel_do_receive(), and there
are probably some reasons it's so far from the bond check.

Jarek P.
