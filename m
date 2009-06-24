From: Anton Vorontsov <cbouatmailru@gmail.com>
Subject: Re: [PATCH] gianfar: Fix half-duplex operation for non-MII/RMII
	interfaces
Date: Thu, 25 Jun 2009 01:50:41 +0400
Message-ID: <20090624215041.GA8416@oksana.dev.rtsoft.ru>
References: <20090624182734.GA14306@oksana.dev.rtsoft.ru> <ED58F994-6BDC-4496-8445-EA1D984F1379@freescale.com> <20090624211038.GA29555@oksana.dev.rtsoft.ru> <FFCBF074-5F39-4D0C-A0C3-F488A619C821@freescale.com> <20090624213945.GB4163@oksana.dev.rtsoft.ru>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: David Miller <davem@davemloft.net>,
	Kumar Gala <galak@kernel.crashing.org>,
	Li Yang <leoli@freescale.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:51311 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751654AbZFXVvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 17:51:48 -0400
Received: by fxm9 with SMTP id 9so1073413fxm.37
        for <netdev@vger.kernel.org>; Wed, 24 Jun 2009 14:51:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090624213945.GB4163@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 25, 2009 at 01:39:45AM +0400, Anton Vorontsov wrote:
> On Wed, Jun 24, 2009 at 04:25:06PM -0500, Andy Fleming wrote:
> [...]
> >>> My concern is that you will be detecting the GMII interface, and
> >>> disallowing half-duplex, despite the fact that the interface is  
> >>> actually
> >>> running at 10 or 100 Mbit.
> >>
> >> Very interesting, though I'm not sure I'm completely following. :-)
> >>
> >> Are you saying that I should do this instead:
> >>
> >> 	if (!phydev->duplex &&
> >> 			(phyi == PHY_INTERFACE_MODE_MII ||
> >> 			 phyi == PHY_INTERFACE_MODE_RMII ||
> >> 			 (phyi == PHY_INTERFACE_MODE_GMII &&
> >> 			  phydev->speed < 1000)))
> >> 		tempval &= ~MACCFG2_FULL_DUPLEX;
> >> 	else
> >> 		tempval |= MACCFG2_FULL_DUPLEX;
> >>
> >> i.e. we detected GMII interface initially, but it downgraded
> >> to MII since speed is < 1000, thus we can set half-duplex in MAC?
> >
> > Yeah, I think that works out more correctly.
> 
> Cool, thanks.
> 
> Do you happen to know how gianfar iface auto-detection works in HW?
> I mean, if we connect 100 Mbs link to the GMII PHY, then
> gfar_get_interface() would return MII, correct?

Stupid me. HW has nothing to do with this. GMII, just as you said,
is just a marker, comes from FSL_GIANFAR_DEV_HAS_GIGABIT flag.

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
