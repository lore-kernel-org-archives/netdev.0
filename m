From: Patrick McHardy <kaber@trash.net>
Subject: Re: [GIT] Networking
Date: Thu, 2 May 2013 09:03:37 +0200
Message-ID: <20130502070256.GA29502@macbook.localnet>
References: <CA+55aFzsvyQLLKbuETBqfhpgkSaXH9cvT0O-cQ-mTTXXxcMqwg@mail.gmail.com>
 <CA+55aFzinZSQAS6GW6vYOyQ06+GSMqkCGb8Fu829s_MxY0L0QA@mail.gmail.com>
 <CA+55aFxoP1vybnqdDwGmd-m0j=x=KDm7GHV6J1i8wGOaU0=5qw@mail.gmail.com>
 <20130502.024552.1513488878160820332.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, hayeswang@realtek.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61585 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910Ab3EBHI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 03:08:29 -0400
Content-Disposition: inline
In-Reply-To: <20130502.024552.1513488878160820332.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 02, 2013 at 02:45:52AM -0400, David Miller wrote:
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Wed, 1 May 2013 21:55:38 -0700
> 
> > I think the positions of those bits matter, and adding
> > NETIF_F_HW_VLAN_STAG_*_BIT randomly in the middle broke things. That's
> > backed up by the fact that we have things like
> > 
> >       __UNUSED_NETIF_F_1
> > 
> > and
> > 
> >           /**/NETIF_F_GSO_SHIFT,          /* keep the order of SKB_GSO_* bits */
> >         NETIF_F_TSO_BIT                 /* ... TCPv4 segmentation */
> >                 = NETIF_F_GSO_SHIFT,
> > 
> > in that array. There is some ordering, and there is some meaning to
> > the bit numbers, and adding the *_STAG_* bits in the middle broke some
> > subtle dependency.
> 
> The other thing this does is it pushes some bits past bit 31.
> 
> netdev_features_t, which holds these masks, is 64-bit but we've
> already seen one place in a driver where a 32-bit value was being
> used.
> 
> I'll look more deeply into this, thanks.

I'll also have a look at this.
