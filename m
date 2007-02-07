From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] bcm43xx: Fix incorrect definition of PHY revision
Date: Wed, 7 Feb 2007 15:14:16 +0100
Message-ID: <200702071514.17516.mb@bu3sch.de>
References: <45c94821.qjljSnUzfws7mU7T%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de, linux-wireless@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:35260
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161329AbXBGOO4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 09:14:56 -0500
In-Reply-To: <45c94821.qjljSnUzfws7mU7T%Larry.Finger@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 07 February 2007 04:31, Larry Finger wrote:
> There is a typographical error in the spefications that interchange the PHY version
> and revision. Fixing this error makes all BCM43xx varieties work at full CCCK rates.
> 
> Signed-off-by: Larry Finger<Larry.Finger@lwfinger.net>
> ---
> 
> John,
> 
> This patch should be put into wireless-2.6 and into 'upstream' as soon as possible.
> I will be sending it to stable for inclusion in 2.6.20.1, and whatever other kernels
> are still being maintained by -stable.
> 
> Larry
> ---
>  
> Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> ===================================================================
> --- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> +++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> @@ -3704,9 +3704,9 @@ static int bcm43xx_read_phyinfo(struct b
>  
>  	value = bcm43xx_read16(bcm, BCM43xx_MMIO_PHY_VER);
>  
> -	phy_version = (value & 0xF000) >> 12;
> +	phy_rev = (value & 0xF000) >> 12;
>  	phy_type = (value & 0x0F00) >> 8;
> -	phy_rev = (value & 0x000F);
> +	phy_version = (value & 0x000F);
>  
>  	dprintk(KERN_INFO PFX "Detected PHY: Version: %x, Type %x, Revision %x\n",
>  		phy_version, phy_type, phy_rev);


I don't think this is correct.
>From which part of the specs did you get this?
http://bcm-v4.sipsolutions.net/802.11/PHY is where the PHY_Version
register is explained. "phy_version"=="AnalogType"

Actually it is possible that phy_revision is mask 0xFF, but that's
not too important at the moment, as we don't have revisions>0xF, yet.

But besides that, it's interresting that this "fixes" things for you.

Especially since wireless-2.6 has no support for hw-power-control, which
is needed by cards 4318 and newer.

-- 
Greetings Michael.
