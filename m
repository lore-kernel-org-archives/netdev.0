From: Jamie Iles <jamie@jamieiles.com>
Subject: Re: [PATCH 1/8] macb: unify at91 and avr32 platform data
Date: Fri, 11 Mar 2011 13:25:36 +0000
Message-ID: <20110311132536.GE7357@pulham.picochip.com>
References: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
 <1299751843-9743-2-git-send-email-jamie@jamieiles.com>
 <4D78CCBC.2010807@atmel.com>
 <20110310131724.GG6198@pulham.picochip.com>
 <20110311014140.GI9351@game.jcrosoft.org>
 <20110311085605.GK6198@pulham.picochip.com>
 <20110311125246.GL9351@game.jcrosoft.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Iles <jamie@jamieiles.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51644 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751278Ab1CKNZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2011 08:25:54 -0500
Received: by wya21 with SMTP id 21so2400029wya.19
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2011 05:25:53 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20110311125246.GL9351@game.jcrosoft.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 11, 2011 at 01:52:46PM +0100, Jean-Christophe PLAGNIOL-VILLARD wrote:
> On 08:56 Fri 11 Mar     , Jamie Iles wrote:
> > On Fri, Mar 11, 2011 at 02:41:40AM +0100, Jean-Christophe PLAGNIOL-VILLARD wrote:
> > > keep as we need to remove the #ifdef AT91 to cpu_is
> > > 
> > > I've patch for this
> > 
> > Is this for the user IO register where the value written is conditional 
> > on both RMII/MII and arch type?
> yes for 
> 
> #if defined(CONFIG_ARCH_AT91)
> 		macb_writel(bp, USRIO, (MACB_BIT(RMII) | MACB_BIT(CLKEN)));
> #else
> 		macb_writel(bp, USRIO, 0);
> #endif
> 	else
> #if defined(CONFIG_ARCH_AT91)
> 		macb_writel(bp, USRIO, MACB_BIT(CLKEN));
> #else
> 		macb_writel(bp, USRIO, MACB_BIT(MII));
> #endif

Ok, but what about non-AT91/AVR32 systems?  They may not have a 
mach/cpu.h and won't have cpu_is_foo() for the platforms the driver is 
interested in.

Could we supply these values in the platform data so the driver doesn't 
need to do any cpu_is_ magic?

Jamie
