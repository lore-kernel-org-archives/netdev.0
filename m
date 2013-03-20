From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH v3 1/1 net-next] NET: FEC: dynamtic check DMA desc buff type
Date: Wed, 20 Mar 2013 15:06:23 -0300
Message-ID: <CAOMZO5BZ6Zqowd+gCXFy9QbU0HKD1HAsy+a_-cZuYQujHLgoXg@mail.gmail.com>
References: <1357265063-30528-1-git-send-email-Frank.Li@freescale.com>
	<20130320160418.GG20530@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Frank Li <Frank.Li@freescale.com>, lznuaa@gmail.com,
	davem@davemloft.net, s.hauer@pengutronix.de,
	netdev@vger.kernel.org, shawn.guo@linaro.org,
	linux-arm-kernel@lists.infradead.org, kernel@pengutronix.de
To: =?UTF-8?Q?Uwe_Kleine=2DK=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f182.google.com ([209.85.220.182]:48038 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051Ab3CTSGY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 14:06:24 -0400
Received: by mail-vc0-f182.google.com with SMTP id ht11so1592544vcb.27
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 11:06:24 -0700 (PDT)
In-Reply-To: <20130320160418.GG20530@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 20, 2013 at 1:04 PM, Uwe Kleine-K=C3=B6nig
<u.kleine-koenig@pengutronix.de> wrote:
> Hello,
>
> On Fri, Jan 04, 2013 at 10:04:23AM +0800, Frank Li wrote:
>> MX6 and mx28 support enhanced DMA descriptor buff to support 1588
>> ptp. But MX25, MX3x, MX5x can't support enhanced DMA descriptor buff=
=2E
>> Check fec type and choose correct DMA descriptor buff type.
>>
>> Remove static config CONFIG_FEC_PTP.
>> ptp function will be auto detected.
> Your patch (now as ff43da86c69d76a726ffe7d1666148960dc1d108 in v3.9-r=
c1)
> breaks building with CONFIG_FEC=3Dm:
>
>         ERROR: "fec_ptp_init" [drivers/net/ethernet/freescale/fec.ko]=
 undefined!
>         ERROR: "fec_ptp_ioctl" [drivers/net/ethernet/freescale/fec.ko=
] undefined!
>         ERROR: "fec_ptp_start_cyclecounter" [drivers/net/ethernet/fre=
escale/fec.ko] undefined!

What about this fix?

---
 drivers/net/ethernet/freescale/fec_ptp.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec_ptp.c
b/drivers/net/ethernet/freescale/fec_ptp.c
index 1f17ca0..0d8df40 100644
--- a/drivers/net/ethernet/freescale/fec_ptp.c
+++ b/drivers/net/ethernet/freescale/fec_ptp.c
@@ -128,6 +128,7 @@ void fec_ptp_start_cyclecounter(struct net_device *=
ndev)

 	spin_unlock_irqrestore(&fep->tmreg_lock, flags);
 }
+EXPORT_SYMBOL(fec_ptp_start_cyclecounter);

 /**
  * fec_ptp_adjfreq - adjust ptp cycle frequency
@@ -318,6 +319,7 @@ int fec_ptp_ioctl(struct net_device *ndev, struct
ifreq *ifr, int cmd)
 	return copy_to_user(ifr->ifr_data, &config, sizeof(config)) ?
 	    -EFAULT : 0;
 }
+EXPORT_SYMBOL(fec_ptp_ioctl);

 /**
  * fec_time_keep - call timecounter_read every second to avoid timer o=
verrun
@@ -383,3 +385,4 @@ void fec_ptp_init(struct net_device *ndev, struct
platform_device *pdev)
 		pr_info("registered PHC device on %s\n", ndev->name);
 	}
 }
+EXPORT_SYMBOL(fec_ptp_init);
--=20
1.7.9.5
