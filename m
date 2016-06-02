From: Scott Wood <oss@buserror.net>
Subject: Re: [PATCH 4/4] Revert "powerpc/fsl: Move fsl_guts.h out of
 arch/powerpc"
Date: Wed, 01 Jun 2016 20:24:20 -0500
Message-ID: <1464830660.22191.6.camel@buserror.net>
References: <1462417950-46796-1-git-send-email-yangbo.lu@nxp.com>
	 <HE1PR04MB0889852B7809A1CCFF8922ACF8410@HE1PR04MB0889.eurprd04.prod.outlook.com>
	 <CAPDyKFqx2JMLzXoDxGCKFYMFV47+SegnkuWFXKvsQHK7L5w-1g@mail.gmail.com>
	 <5513501.AmZs7h1vI2@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ulf Hansson <ulf.hansson@linaro.org>,
	Yangbo Lu <yangbo.lu@nxp.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Xiaobo Xie <xiaobo.xie@nxp.com>,
	"linux-i2c@vger.kernel.org" <linux-i2c@vger.kernel.org>,
	"linux-clk@vger.kernel.org" <linux-clk@vger.kernel.org>,
	Qiang Zhao <qiang.zhao@nxp.com>,
	Russell King <linux@arm.linux.org.uk>,
	Bhupesh Sharma <bhupesh.sharma@freescale.com>,
	Joerg Roedel <joro@8bytes.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Rob Herring <robh+dt@kernel.org>,
	Santosh Shilimkar <ssantosh@kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Yang-Leo Li <leoyang.li@nxp.com>,
	"iommu
To: Arnd Bergmann <arnd@arndb.de>, linuxppc-dev@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.buserror.net ([209.198.135.123]:58218 "EHLO
	host.buserror.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751479AbcFBBYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 21:24:30 -0400
In-Reply-To: <5513501.AmZs7h1vI2@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-05-30 at 15:18 +0200, Arnd Bergmann wrote:
> All users of this driver are PowerPC specific and the header file
> has no business in the global include/linux/ hierarchy, so move
> it back before anyone starts using it on ARM.
> 
> This reverts commit 948486544713492f00ac8a9572909101ea892cb0.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> This part of the series is not required for the eSDHC quirk,
> but it restores the asm/fsl_guts.h header so it doesn't accidentally
> get abused for this in the future. I found two drivers outside of
> arch/powerpc that already accessed the registers directly, but the
> functions look fairly contained, and can be easily hidden in an
> #ifdef CONFIG_PPC

NACK

Besides adding ifdef pollution for no good reason, this register block is used
on some ARM chips as well.  Why is it a problem if "anyone starts using it on
ARM"?

BTW, of all the mailing lists you included on this CC, you seem to have left
off the PPC list (I've added it).

-Scott
