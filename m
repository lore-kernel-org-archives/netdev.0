From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH v5 1/1 net] net: fec: fix kernel oops when plug/unplug
 cable many times
Date: Tue, 14 May 2013 16:27:04 -0300
Message-ID: <CAOMZO5AUk0GHKj857a0=Q-dxhpO2s7uatXurNVZV_UmEmtGsqQ@mail.gmail.com>
References: <1367971724-1974-1-git-send-email-Frank.Li@freescale.com>
	<20130513045710.GA4440@S2101-09.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Frank Li <Frank.Li@freescale.com>, romieu@fr.zoreil.com,
	r.schwebel@pengutronix.de, davem@davemloft.net,
	l.stach@pengutronix.de, netdev@vger.kernel.org, lznuaa@gmail.com
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f178.google.com ([209.85.128.178]:33095 "EHLO
	mail-ve0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755376Ab3ENT1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 May 2013 15:27:06 -0400
Received: by mail-ve0-f178.google.com with SMTP id jy13so1111145veb.23
        for <netdev@vger.kernel.org>; Tue, 14 May 2013 12:27:04 -0700 (PDT)
In-Reply-To: <20130513045710.GA4440@S2101-09.ap.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 13, 2013 at 1:57 AM, Shawn Guo <shawn.guo@linaro.org> wrote:

> The patch has landed on 3.10-rc1.  Seems that it introduces a lock
> warning as below.  Turn on CONFIG_PROVE_LOCKING and you will be able
> to see it.

This makes the warning goes away on mx28:

--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -451,7 +451,6 @@ fec_restart(struct net_device *ndev, int duplex)
                netif_device_detach(ndev);
                napi_disable(&fep->napi);
                netif_stop_queue(ndev);
-               netif_tx_lock(ndev);
        }

        /* Whack a reset.  We should wait for this. */
@@ -619,7 +618,6 @@ fec_restart(struct net_device *ndev, int duplex)
                netif_device_attach(ndev);
                napi_enable(&fep->napi);
                netif_wake_queue(ndev);
-               netif_tx_unlock(ndev);
        }
 }

,but not sure if it looks OK.
