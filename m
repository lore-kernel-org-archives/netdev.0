From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: enable rx/tx in sky2_phy_reinit()
Date: Mon, 12 Jul 2010 08:48:54 -0700
Message-ID: <20100712084854.7e4f2e4d@nehalam>
References: <20100617022158.GA4135@jenkins.ifup.org>
	<AANLkTilzHA_URoZONtMf6A9-IRV4wA2ncr0b8Jff1ge9@mail.gmail.com>
	<20100623170008.GN14143@jenkins.ifup.org>
	<20100712110410.GA13679@chota.scz.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Mike McCormack <mikem@ring3k.org>
To: Brandon Philips <brandon@ifup.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51809 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756117Ab0GLPtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jul 2010 11:49:18 -0400
In-Reply-To: <20100712110410.GA13679@chota.scz.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 Jul 2010 04:04:10 -0700
Brandon Philips <brandon@ifup.org> wrote:

> On 10:00 Wed 23 Jun 2010, Brandon Philips wrote:
> > While testing this I just noticed that if I turn off speed autoneg the
> > interface stops sending packets until I turn off pause autoneg too.
> > 
> > To illustrate start pinging some machine and run this:
> > 
> >  $ ethtool --change eth0 speed 100 duplex full autoneg off
> >  # At this point the ping stops
> > 
> >  $ ethtool -A eth0 autoneg off
> >  # Ping starts up again
> > 
> > When I tried capturing packets nothing was coming from the device.
> > 
> > 0ea065e52eb6a0f029b5fa5ed2f142be1b66a153 implemeneted the behaviour of
> > having seperate pause and speed ethtool controls for sky2. Reverting
> > this (see quick ugly revert below) obviously fixes the issue.
> > 
> > Any ideas on how to fix this in a proper way though?

No quick ideas; try doing walkthrough with debugging to see what PHY
interrupt status is.
