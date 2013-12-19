From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: FEC performance degradation with certain packet sizes
Date: Thu, 19 Dec 2013 15:04:59 -0800
Message-ID: <1387494299.19078.378.camel@edumazet-glaptop2.roam.corp.google.com>
References: <528F50AE.3030804@digi.com> <201311240540.23813.marex@denx.de>
	 <529310A4.70906@digi.com> <52B1D0C6.6010305@digi.com>
	 <1387388339.19078.321.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0afcc48493b941ffab991d52b7c97a0d@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hector Palacios <hector.palacios@digi.com>,
	Marek Vasut <marex@denx.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Fabio.Estevam@freescale.com" <Fabio.Estevam@freescale.com>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"l.stach@pengutronix.de" <l.stach@pengutronix.de>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:63685 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755215Ab3LSXFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 18:05:01 -0500
Received: by mail-pa0-f42.google.com with SMTP id lj1so1813310pab.29
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 15:05:00 -0800 (PST)
In-Reply-To: <0afcc48493b941ffab991d52b7c97a0d@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-19 at 02:44 +0000, fugang.duan@freescale.com wrote:

> Enet IP don't support tso feature.
> 
> I will reproduce the issue in imx6q/dl sd platform, and analyze the issue.
> Previous test, we don't use netpipe tool test ethernet performance.

drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c seems broken...

If tx_skb_align_workaround() returns NULL, returning NETDEV_TX_BUSY 
is the worst possible thing to do.

Packet should be dropped instead.

Probably not related to your issue.
