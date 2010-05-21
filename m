From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: bnx2x + SFP+ DA/2.6.33.3: Got bad status 0x0 when reading
 from SFP+ EEPROM -> SFP+ module is not initialized
Date: Fri, 21 May 2010 15:58:33 +0300
Message-ID: <1274446713.11082.3.camel@lb-tlvb-eilong.il.broadcom.com>
References: <4BF56CA6.8080306@ans.pl>
 <1274377770.28702.4.camel@lb-tlvb-eilong.il.broadcom.com>
 <4BF57ADF.1060203@ans.pl>
 <1274381113.28702.6.camel@lb-tlvb-eilong.il.broadcom.com>
 <4BF59058.6050205@ans.pl> <4BF59ABB.9070600@hp.com>
 <4BF5A19E.5010003@ans.pl>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rick Jones" <rick.jones2@hp.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Krzysztof =?UTF-8?Q?Ol=C4=99dzki?=" <ole@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4985 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753238Ab0EUM6s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 08:58:48 -0400
In-Reply-To: <4BF5A19E.5010003@ans.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-05-20 at 13:54 -0700, Krzysztof Ol=C4=99dzki wrote:
> On 2010-05-20 22:25, Rick Jones wrote:
> > Some simple/simplistic thoughts/questions...
> >
> > Has the DAC been used successfully prior to this?
>=20
> Yes. It was successfully used to connect two HP switches, before I=20
> received SFP+ SR modules, that allowed me to put the switches into=20
> distanced rooms.

Krzysztof,

I would like to check in what speed the I2C is running at, and while we
are there, to make sure it is at low speed (100KHz and not 400KHz). Can
you please add this patch and let me know what you see:

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index ff70be8..6e05f99 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -2766,6 +2766,21 @@ static u8
bnx2x_8727_read_sfp_module_eeprom(struct link_params *params,
                      MDIO_PMA_REG_SFP_TWO_WIRE_CTRL,
                      &val);
=20
+       /* Make sure we are working in 100KHz */
+       bnx2x_cl45_read(bp, port,
+                     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727,
+                     ext_phy_addr,
+                     MDIO_PMA_DEVAD,
+                     8005,
+                     &val);
+       BNX2X_ERR("I2C 2W speed 0x%x, bit 8 %d\n", val, val & 8);
+       bnx2x_cl45_write(bp, port,
+                      ext_phy_type,
+                      ext_phy_addr,
+                      MDIO_PMA_DEVAD,
+                      8005,
+                      val & ~8);
+
        /* Set the read command byte count */
        bnx2x_cl45_write(bp, port,
                       ext_phy_type,

Since we are already off for the weekend, I couldn't find a machine wit=
h
this kind of board to test it for myself. On top of that, I don't have
this type of DAC cable, so I need your help in this debug process.

Thanks,
Eilon



