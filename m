From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH,RESEND] smc91x: disable DMA mode on the logicpd pxa270
Date: Sat, 12 Aug 2006 11:30:35 +0200
Message-ID: <20060812093035.GB693@xi.wantstofly.org>
References: <20060812085506.GA650@xi.wantstofly.org> <20060812092752.GN4745@rhun.haifa.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, nico@cam.org,
	mikee@logicpd.com, peterb@logicpd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:57255 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S1751415AbWHLJag
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Aug 2006 05:30:36 -0400
To: Muli Ben-Yehuda <muli@il.ibm.com>
Content-Disposition: inline
In-Reply-To: <20060812092752.GN4745@rhun.haifa.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 12, 2006 at 12:27:52PM +0300, Muli Ben-Yehuda wrote:

> > Enabling PXA DMA for the smc91x on the logicpd pxa270 produces
> > unacceptable interference with the TFT panel, so disable it.
> 
> Doesn't this disable it for all users, though?

Nope.  Unfortunately, the line that made that clear didn't fall inside
the patch context:

	[...]

	#define SMC_inb(a, r)           readb((a) + (r))
	#define SMC_outb(v, a, r)       writeb(v, (a) + (r))
	#define SMC_insb(a, r, p, l)    readsb((a) + (r), p, (l))
	#define SMC_outsb(a, r, p, l)   writesb((a) + (r), p, (l))

	#elif   defined(CONFIG_MACH_LOGICPD_PXA270)		<====

	#define SMC_CAN_USE_8BIT        0
	#define SMC_CAN_USE_16BIT       1
	#define SMC_CAN_USE_32BIT       0
	#define SMC_IO_SHIFT            0
	#define SMC_NOWAIT              1
	#define SMC_USE_PXA_DMA         1

	[...]


cheers,
Lennert
