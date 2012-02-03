From: Fabio Estevam <festevam@gmail.com>
Subject: Re: Regulator support for smsc911x
Date: Fri, 3 Feb 2012 01:17:23 -0200
Message-ID: <CAOMZO5Be_0W6E7Vj7YDLwFUhrqt_7Q748rpj=J2Tbyh9+MP7gQ@mail.gmail.com>
References: <CAOMZO5Bn4jMYjcBC87uD99qYgzXdiH6YxD5xakjftH-U6bbzMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Sascha Hauer <kernel@pengutronix.de>,
	Mark Brown <broonie@opensource.wolfsonmicro.com>
To: robert.marklund@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:46518 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754747Ab2BCDRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 22:17:24 -0500
Received: by eaah12 with SMTP id h12so1279571eaa.19
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2012 19:17:23 -0800 (PST)
In-Reply-To: <CAOMZO5Bn4jMYjcBC87uD99qYgzXdiH6YxD5xakjftH-U6bbzMQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 2, 2012 at 11:02 PM, Fabio Estevam <festevam@gmail.com> wrote:
> Robert,
>
> Since commit c7e963f6 (net/smsc911x: Add regulator support) I am no
> longer able to use smsc911x driver due to the lack of regulators for
> smsc on mx31_3ds board.
>
> Do you a board example that uses such regulator, so that I can look
> for a reference?

Ok, I fixed it by enabling CONFIG_REGULATOR_DUMMY on
imx_v6_v7_defconfig, but I am wondering if the patch below would be a
more appropriate fix:

--- a/drivers/net/ethernet/smsc/Kconfig
+++ b/drivers/net/ethernet/smsc/Kconfig
@@ -102,6 +102,8 @@ config SMSC911X
        select NET_CORE
        select MII
        select PHYLIB
+       select REGULATOR
+       select REGULATOR_DUMMY
        ---help---
          Say Y here if you want support for SMSC LAN911x and LAN921x families
          of ethernet controllers.

Please advise if I should fix it in Kconfig or defconfig, so that I
can submit a patch.

Regards,

Fabio Estevam
