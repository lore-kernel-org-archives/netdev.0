From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] cs89x0: add support for i.MX31ADS ARM board
Date: Tue, 16 Sep 2008 14:52:28 +0200
Message-ID: <20080916125228.GA19104@xi.wantstofly.org>
References: <489DD049.6020106@xenomai.org> <48CC5B03.2020003@garzik.org> <20080914120358.GA26748@xi.wantstofly.org> <48CD1C19.60803@xenomai.org> <20080916124422.GC18556@xi.wantstofly.org> <48CFAAE5.80805@xenomai.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Russell King <rmk@arm.linux.org.uk>
To: Gilles Chanteperdrix <gilles.chanteperdrix@xenomai.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:41842 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257AbYIPMw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 08:52:29 -0400
Content-Disposition: inline
In-Reply-To: <48CFAAE5.80805@xenomai.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 16, 2008 at 02:47:33PM +0200, Gilles Chanteperdrix wrote:

> >>> I don't have the original patch in my netdev box anymore, but what
> >>> seems to me should be done is to add a platform driver interface to
> >>> the cs89x0 driver, like how most other non-PCI non-other-autoconf-
> >>> supporting-bus net drivers do it.  (There aren't too many -- grep
> >>> for platform_driver_register in drivers/net/*)
> >>>
> >>> Then the knowledge about I/O addresses and IRQ lines can live in the
> >>> platform code (where it belongs) instead of having it all in the driver
> >>> (where it doesn't belong).  And all the IXDP2351 and IXDP2X01 ifdefs
> >>> can disappear as well.  And the ->readword()/->writeword() hacks that
> >>> need to be done for IXDP2351 and IXDP2X01 and PNX can then just be an
> >>> (optional) set of platform data methods, with a fallback to the default
> >>> one if they aren't passed in.
> >>>
> >>> The question is whether someone wants to step up and do that work.
> >>> cs89x0 has seen a lot of drive-by patching by people looking to satisfy
> >>> their needs, but noone has stepped up to give it the proper love and
> >>> care that it deserves.
> >>>
> >>> Gilles, are you willing to do the platform driver conversion?  If not,
> >>> then I guess we should just merge this patch as-is (after you explain
> >>> why you need to stub out reset_chip() on your board, as no other board
> >>> seems to need this?).
> >> Hi Lennert,
> >>
> >> When I published this patch, I had access to an i.MX31ADS board, and
> >> getting Linux to work on this board was just a necessity to get my job
> >> done. I did this by copying the parts I needed working (the serial
> >> console and ethernet driver) from the Freescale tree.
> >>
> >> Now, I am no longer working on this, so I can not test any modification.
> >> And I do not even know why people at Freescale did what they did.
> > 
> > I guess then we should just wait until the Freescale people submit it.
> 
> I will be able to test the modification soon. I will repost the patch on
> linux-arm-kernel after this test.

OK.  Please also try leaving reset_chip() as it is and see if it still
works like that -- I suspect that that part of the patch might have been
a debug leftover.
