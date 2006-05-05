From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Machine check in bcm43xx_phy_initg
Date: Fri, 5 May 2006 19:42:39 +0200
Message-ID: <200605051942.39552.mb@bu3sch.de>
References: <1146847015.2766.10.camel@pmac.infradead.org> <445B8474.302@gentoo.org> <1146849577.2766.18.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org, David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:4032
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751687AbWEERgX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 May 2006 13:36:23 -0400
To: linville@tuxdriver.com
In-Reply-To: <1146849577.2766.18.camel@pmac.infradead.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 05 May 2006 19:19, David Woodhouse wrote:
> On Fri, 2006-05-05 at 12:59 -0400, Joseph Jezak wrote:
> > I fixed the specs, it should be bcm->chip_package == 2, sorry for the
> > mistake.
> 
> Thanks. The correct patch should look like this then...
> 
> [BCM43xx] Fix access to non-existent PHY registers
> 
> Fix the conditions under which we poke at the APHY registers in
> bcm43xx_phy_initg() to avoid a machine check on chips where they don't
> exist.
> 
> Signed-off-by: David Woodhouse <dwmw2@infradead.org>

Signed-off-by: Michael Buesch <mb@bu3sch.de>

John, please apply. I will also send a patch for d80211.

> --- linux-2.6.16.ppc64/drivers/net/wireless/bcm43xx/bcm43xx_phy.c~	2006-05-04 19:16:09.000000000 +0100
> +++ linux-2.6.16.ppc64/drivers/net/wireless/bcm43xx/bcm43xx_phy.c	2006-05-05 17:22:57.000000000 +0100
> @@ -1287,7 +1287,7 @@ static void bcm43xx_phy_initg(struct bcm
>  	if (radio->revision == 8)
>  		bcm43xx_phy_write(bcm, 0x0805, 0x3230);
>  	bcm43xx_phy_init_pctl(bcm);
> -	if (bcm->chip_id == 0x4306 && bcm->chip_package != 2) {
> +	if (bcm->chip_id == 0x4306 && bcm->chip_package == 2) {
>  		bcm43xx_phy_write(bcm, 0x0429,
>  				  bcm43xx_phy_read(bcm, 0x0429) & 0xBFFF);
>  		bcm43xx_phy_write(bcm, 0x04C3,
> 

-- 
Greetings Michael.
