From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH] fec: Unify fec_ptp.c and fec.c
Date: Thu, 21 Mar 2013 18:02:02 +0800
Message-ID: <CAHrpEqTd2mVaTW6pwJaHqYreDo6rT_6s_o=Z=OtU71PZzZCSVg@mail.gmail.com>
References: <1363810268-24398-1-git-send-email-festevam@gmail.com>
	<20130321062146.GL20530@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fabio Estevam <festevam@gmail.com>, davem@davemloft.net,
	Frank.Li@freescale.com, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: =?ISO-8859-1?Q?Uwe_Kleine=2DK=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:48881 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757594Ab3CUKCF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 06:02:05 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr12so2036978wgb.11
        for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 03:02:02 -0700 (PDT)
In-Reply-To: <20130321062146.GL20530@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I suggest use below patch to fix this problem

--- a/drivers/net/ethernet/freescale/Makefile
+++ b/drivers/net/ethernet/freescale/Makefile
@@ -2,7 +2,8 @@
 # Makefile for the Freescale network device drivers.
 #

-obj-$(CONFIG_FEC) +=3D fec.o fec_ptp.o
+obj-$(CONFIG_FEC) +=3D fec_driver.o
+fec_driver-objs :=3D fec.o fec_ptp.o
 obj-$(CONFIG_FEC_MPC52xx) +=3D fec_mpc52xx.o
 ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
        obj-$(CONFIG_FEC_MPC52xx) +=3D fec_mpc52xx_phy.o


2013/3/21 Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>:
> Hello Fabio,
>
> On Wed, Mar 20, 2013 at 05:11:07PM -0300, Fabio Estevam wrote:
>> Currently CONFIG_FEC=3Dy generates two separate modules: fec_ptp.ko =
and fec.ko.
> CONFIG_FEC=3Dm
>
>> These modules cannot be used independently, so it is better to unify=
 them.
>>
>> Move fec_ptp.c code into fec.c and its definitions into fec.h.
>>
>> Suggested-by: Uwe Kleine-Koenig <u.kleine-koenig@pengutronix.de>
> s/Koe/K=F6/
>
>> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
>
> You could note that you dropped the EXPORT_SYMBOLs. Other than that I
> assume it's a 1:1 change?
>
> Best regards
> Uwe
>
> --
> Pengutronix e.K.                           | Uwe Kleine-K=F6nig      =
      |
> Industrial Linux Solutions                 | http://www.pengutronix.d=
e/  |
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
