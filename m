From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] net: fec: stop the "rcv is not +last, " error messages
Date: Wed, 30 Mar 2016 15:37:15 -0300
Message-ID: <CAOMZO5B79aHocuqT4jgEU9gGcFYD5ZSDZh8PrGeXYAcLHW1x5Q@mail.gmail.com>
References: <56FB46EA.7050401@uclinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Troy Kisky <troy.kisky@boundarydevices.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Greg Ungerer <gerg@uclinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:36638 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752250AbcC3ShQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 14:37:16 -0400
Received: by mail-io0-f179.google.com with SMTP id q128so83333561iof.3
        for <netdev@vger.kernel.org>; Wed, 30 Mar 2016 11:37:16 -0700 (PDT)
In-Reply-To: <56FB46EA.7050401@uclinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Greg,

On Wed, Mar 30, 2016 at 12:24 AM, Greg Ungerer <gerg@uclinux.org> wrote:
> Hi Troy,
>
> Commit 55cd48c8 ('net: fec: stop the "rcv is not +last, " error
> messages') adds a write to a register that is not present in all
> implementations of the FEC hardware module. None of the ColdFire
> SoC parts with the FEC module have the FTRL (0x1b0) register.
>
> Does this need a quirk flag to key access to this register of?
> Or can you piggyback on the FEC_QUIRK_HAS_RACC flag?

Would the change below work on Coldfire?

--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -943,8 +943,8 @@ fec_restart(struct net_device *ndev)
                else
                        val &= ~FEC_RACC_OPTIONS;
                writel(val, fep->hwp + FEC_RACC);
-       }
        writel(PKT_MAXBUF_SIZE, fep->hwp + FEC_FTRL);
+       }
 #endif

        /*
