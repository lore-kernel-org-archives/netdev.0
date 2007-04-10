From: Kim Phillips <kim.phillips@freescale.com>
Subject: Re: phylib usage
Date: Tue, 10 Apr 2007 17:20:52 -0500
Message-ID: <20070410172052.16eae78c.kim.phillips@freescale.com>
References: <1176230461.7526.20.camel@dhollis-lnx.sunera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Hollis <dhollis@davehollis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:61437 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030400AbXDJWU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 18:20:58 -0400
In-Reply-To: <1176230461.7526.20.camel@dhollis-lnx.sunera.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 10 Apr 2007 14:41:01 -0400
David Hollis <dhollis@davehollis.com> wrote:

> I've been keeping an eye on PHYLIB since it's addition to the kernel
> some time ago and I'm a bit curious as to why it doesn't seem to have
> much up-take among other drivers.  A quick check of the kernel source
> shows only two users (AU1000 and gianfar) and both look to be embedded
> type devices.  Are there fundamental issues with PHYLIB that prevent
> it

I just posted patches for ucc_geth to use phylib.

> from being more widely used?  Is it an element of "the driver ain't
> broke, I'm not going to rework my PHY handling at this point"?  Is PHY

I think that could very well be it, at least until your nic gets a new phy
(like the ucc_geth just did :).

> handling something that is just too difficult to fully abstract with
> various specialty nics?
> 
> To semi-answer one of my own questions, I was hoping to use PHYLIB
> with asix.c (a USB Ethernet driver) since the newer devices now have
> external PHYs and it appears that there are quite a few different ones
> in use by
> various OEMs but I found that the locking in use wasn't amenable to
> USB operations, since USB calls can sleep.  This doesn't seem like an
> insurmountable problem however.
> 
> The main reason I even ask is that it seems rather odd to have so many
> drivers that seem to have the same PHY's and yet each driver has to
> deal with various errata and quirks of the PHY.  Having it all
> abstracted makes for one location to deal with things and everybody
> wins.

The main reason behind the phylib I thought was resource control
(no two nic drivers trying to access the same phy at the same time),
but yes, you simply cannot understate the convenience it provides to the
PHY driver duplication/porting problem as a whole.

(note I'm coming from an embedded world here.)

Kim
