From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH] netdev/fec.c: add phylib supporting to enable carrier
	detection
Date: Wed, 31 Mar 2010 09:57:46 +0200
Message-ID: <20100331075746.GO2241@pengutronix.de>
References: <1269597052-10104-1-git-send-email-bryan.wu@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gerg@uclinux.org, amit.kucheria@canonical.com,
	kernel-team@lists.ubuntu.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	w.sang@pengutronix.de
To: Bryan Wu <bryan.wu@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:58777 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757227Ab0CaH5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 03:57:49 -0400
Content-Disposition: inline
In-Reply-To: <1269597052-10104-1-git-send-email-bryan.wu@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 26, 2010 at 05:50:52PM +0800, Bryan Wu wrote:
> BugLink: http://bugs.launchpad.net/bugs/457878
> 
>  - removed old MII phy control code
>  - add phylib supporting
>  - add ethtool interface to make user space NetworkManager works
> 
> Tested on Freescale i.MX51 Babbage board.
> 
> This patch is based on a patch from Frederic Rodo <fred.rodo@gmail.com>
> 


Hi Bryan,

The MII speed is calculated twice with this patch applied, one time
in fec_enet_mii_init and one time in fec_enet_init.

The patch didn't work for me because the calculation is wrong (which of
course is not your fault, it was wrong before).
According to the Datasheet the MII clock is clk_get_rate() / (MII * 2).
When we want to have a clock of 2.5MHz we have to do:

clk_get_rate() / 5000000

With rounding this would be:

(clk_get_rate() + 4999999) / 5000000

So you might want to add the following to your patch:

	fep->phy_speed = ((clk_get_rate(fep->clk) + 4999999) / 5000000) << 1;

Otherwise the patch looks good to me.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
