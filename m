From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH 03/10] net/fec: add mac field into platform data and
 consolidate fec_get_mac
Date: Thu, 30 Dec 2010 12:29:00 +0800
Message-ID: <20101230042858.GA20651@freescale.com>
References: <1293548155-16328-1-git-send-email-shawn.guo@freescale.com>
 <1293548155-16328-4-git-send-email-shawn.guo@freescale.com>
 <20101229065329.GB31010@jasper.tkos.co.il>
 <20101229100520.GB19347@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <gerg@snapgear.com>, <eric@eukrea.com>,
	<bryan.wu@canonical.com>, <r64343@freescale.com>,
	<B32542@freescale.com>, <u.kleine-koenig@pengutronix.de>,
	<lw@karo-electronics.de>, <w.sang@pengutronix.de>,
	<s.hauer@pengutronix.de>, <linux-arm-kernel@lists.infradead.org>,
	<netdev@vger.kernel.org>
To: Baruch Siach <baruch@tkos.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:31030
	"EHLO VA3EHSOBE009.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751669Ab0L3E04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Dec 2010 23:26:56 -0500
Received: from mail41-va3 (localhost.localdomain [127.0.0.1])	by
 mail41-va3-R.bigfish.com (Postfix) with ESMTP id C29B313583F5	for
 <netdev@vger.kernel.org>; Thu, 30 Dec 2010 04:26:53 +0000 (UTC)
Received: from VA3EHSMHS023.bigfish.com (unknown [10.7.14.252])	by
 mail41-va3.bigfish.com (Postfix) with ESMTP id 7E34A248054	for
 <netdev@vger.kernel.org>; Thu, 30 Dec 2010 04:26:53 +0000 (UTC)
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by az33egw02.freescale.net (8.14.3/8.14.3) with ESMTP id oBU4QoLH028755	for
 <netdev@vger.kernel.org>; Wed, 29 Dec 2010 21:26:51 -0700 (MST)
Received: from ubuntu.localdomain (ubuntu-010192242196.ap.freescale.net
 [10.192.242.196])	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id
 oBU4iZZr018352	for <netdev@vger.kernel.org>; Wed, 29 Dec 2010 22:44:36 -0600
 (CST)
Content-Disposition: inline
In-Reply-To: <20101229100520.GB19347@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Baruch,

On Wed, Dec 29, 2010 at 06:05:20PM +0800, Shawn Guo wrote:
> Hi Baruch,
> 
> On Wed, Dec 29, 2010 at 08:53:30AM +0200, Baruch Siach wrote:
> > Hi Shawn,
> > 
> > Please add netdev@vger.kernel.org to the Cc of all your fec driver patches.
> > 
> > On Tue, Dec 28, 2010 at 10:55:48PM +0800, Shawn Guo wrote:
> > > Add mac field into fec_platform_data and consolidate function
> > > fec_get_mac to get mac address in following order.
> > > 
> > >  1) kernel command line fec_mac=xx:xx:xx...
> > 
> > In the case of dual MAC that you later add support for, the address which one 
> > is being set? Is there a way to set both in kernel command line?
> > 
> The fec0 gets fec_mac and fec1 gets fec_mac + 1. The following code
> in function fec_get_mac takes care of it.
> 
> 	/* Adjust MAC if using default MAC address */
> 	if (iap == fec_mac_default)
> 		dev->dev_addr[ETH_ALEN-1] = fec_mac_default[ETH_ALEN-1] + fep->pdev->id;
> 
> 
> > Also, instead of inventing another kernel command line parameter, it is better 
> > IMO to use the module parameters mechanism. The greth NIC driver already uses 
> > this method for setting MAC address. Look for 'macaddr' in 
> > drivers/net/greth.c, and the explanation at the beginning of 
> > Documentation/kernel-parameters.txt.
> > 
> Sounds good. Thanks.
> 
I just thought this over again. Module parameter might not be
the best here. fec is usually used to mount nfs during boot,
which requires a built-in driver other than module.

-- 
Regards,
Shawn

