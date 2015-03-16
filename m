From: Emil Medve <Emilian.Medve@Freescale.com>
Subject: Re: [linuxppc-release] [PATCH] net/fsl: modify xgmac_mdio for little
 endian SoCs
Date: Mon, 16 Mar 2015 01:56:41 -0500
Message-ID: <55067EA9.7030303@Freescale.com>
References: <1426483371-3286-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Shaohui Xie <Shaohui.Xie@Freescale.com>
To: <shh.xie@gmail.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0122.outbound.protection.outlook.com ([65.55.169.122]:31064
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751796AbbCPHMn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Mar 2015 03:12:43 -0400
In-Reply-To: <1426483371-3286-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Shao-Hui,


On 03/16/2015 12:22 AM, shh.xie@gmail.com wrote:
> From: Shaohui Xie <Shaohui.Xie@freescale.com>
> 
> MDIO controller on little endian Socs, e.g. ls2085a is similar to the
> controller on big endian Socs, but the MDIO access is little endian,
> we use I/O accessor function to handle endianness, so the driver can
> run on little endian Socs. A property "fsl,little-endian-mdio" is used
> in DTS to indicate the MDIO is little endian, if driver probes the
> property, driver will access MDIO in little endian.

Please use "{big,little}-endian" with "big-endian" being the default if
none is present. Please look at
Documentation/devicetree/bindings/regmap/regmap.txt and more then a
dozen FSL bindings already using this

> Also, fix a bug in xgmac_wait_until_done() which mdio_stat should be
> used instead of mdio_data when checking if busy bit is cleared.

Please split this into a separate patch

> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
> ---
>  drivers/net/ethernet/freescale/xgmac_mdio.c | 96 ++++++++++++++++++++---------
>  1 file changed, 68 insertions(+), 28 deletions(-)

Cheers,
