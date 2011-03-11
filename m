From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCH 1/8] macb: unify at91 and avr32 platform data
Date: Fri, 11 Mar 2011 14:37:13 +0100
Message-ID: <20110311133713.GQ9351@game.jcrosoft.org>
References: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
 <1299751843-9743-2-git-send-email-jamie@jamieiles.com>
 <4D78CCBC.2010807@atmel.com>
 <20110310131724.GG6198@pulham.picochip.com>
 <20110311014140.GI9351@game.jcrosoft.org>
 <20110311085605.GK6198@pulham.picochip.com>
 <20110311125246.GL9351@game.jcrosoft.org>
 <20110311132536.GE7357@pulham.picochip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Jamie Iles <jamie@jamieiles.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 64.mail-out.ovh.net ([91.121.185.65]:36781 "HELO
	64.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752191Ab1CKNmn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2011 08:42:43 -0500
Content-Disposition: inline
In-Reply-To: <20110311132536.GE7357@pulham.picochip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13:25 Fri 11 Mar     , Jamie Iles wrote:
> On Fri, Mar 11, 2011 at 01:52:46PM +0100, Jean-Christophe PLAGNIOL-VILLARD wrote:
> > On 08:56 Fri 11 Mar     , Jamie Iles wrote:
> > > On Fri, Mar 11, 2011 at 02:41:40AM +0100, Jean-Christophe PLAGNIOL-VILLARD wrote:
> > > > keep as we need to remove the #ifdef AT91 to cpu_is
> > > > 
> > > > I've patch for this
> > > 
> > > Is this for the user IO register where the value written is conditional 
> > > on both RMII/MII and arch type?
> > yes for 
> > 
> > #if defined(CONFIG_ARCH_AT91)
> > 		macb_writel(bp, USRIO, (MACB_BIT(RMII) | MACB_BIT(CLKEN)));
> > #else
> > 		macb_writel(bp, USRIO, 0);
> > #endif
> > 	else
> > #if defined(CONFIG_ARCH_AT91)
> > 		macb_writel(bp, USRIO, MACB_BIT(CLKEN));
> > #else
> > 		macb_writel(bp, USRIO, MACB_BIT(MII));
> > #endif
> 
> Ok, but what about non-AT91/AVR32 systems?  They may not have a 
> mach/cpu.h and won't have cpu_is_foo() for the platforms the driver is 
> interested in.
> 
> Could we supply these values in the platform data so the driver doesn't 
> need to do any cpu_is_ magic?
for other arch you can but at91 I prefer to avoid this copy and paste in every
soc

Best Regards,
J.
