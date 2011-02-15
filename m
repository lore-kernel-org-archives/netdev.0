From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH] drivers/net: Call netif_carrier_off at the end of the
 probe
Date: Tue, 15 Feb 2011 13:01:03 -0500 (EST)
Message-ID: <483985247.35721.1297792863958.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com>
References: <1297785532.2584.10.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, aabdulla@nvidia.com,
	Ben Hutchings <ben@decadent.org.uk>,
	Francois Romieu <romieu@fr.zoreil.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:49507 "EHLO
	mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754123Ab1BOSBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Feb 2011 13:01:23 -0500
In-Reply-To: <1297785532.2584.10.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----- Original Message -----
> On Tue, 2011-02-15 at 16:22 +0100, Francois Romieu wrote:
> > Stated this way it sounds like a core dev layer issue.
> 
> ...
> > I am not completely sure after reading some history. Namely:
> > - (37e8273cd30592d3a82bcb70cbb1bdc4eaeb6b71 ?)
> > - c276e098d3ee33059b4a1c747354226cec58487c
> > - 22604c866889c4b2e12b73cbf1683bda1b72a313
> > - b47300168e770b60ab96c8924854c3b0eb4260eb
> >
> > I am confused.
> 
> Drivers that can report carrier state should do so initially some time
> between registering a device and bringing it up (either in the bus
> probe
> function or the ndo_open function). It generally seems to be safe to
> assume that the link is down initially, and then to rely on
> notifications from the hardware. However, that does depend on the
> behaviour of the hardware.
> 
Yes,that's true... forcedeth and r8169 are the drivers that detect link
state when device is opened and call netif_carrier_on(off) appropriately.

Ivan
