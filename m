From: Fabio Estevam <festevam@gmail.com>
Subject: Re: commit-3ac72b7b63d5 breaks networking on iMX28
Date: Fri, 21 Oct 2016 08:55:36 -0200
Message-ID: <CAOMZO5ADSSUkTwi3WDHHGX-i-Jm+YbrVzES0BDtGsR1kFTxO+Q@mail.gmail.com>
References: <bc6aa851-3f52-2274-47dc-4933662648a1@ginzinger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Nelson <eric@nelint.com>, Fugang Duan <fugang.duan@nxp.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Henri Roosen <henri.roosen@ginzinger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f44.google.com ([209.85.213.44]:33077 "EHLO
        mail-vk0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754253AbcJUKzi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 06:55:38 -0400
Received: by mail-vk0-f44.google.com with SMTP id 83so110853673vkd.0
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 03:55:37 -0700 (PDT)
In-Reply-To: <bc6aa851-3f52-2274-47dc-4933662648a1@ginzinger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Henri,

2016-10-21 7:19 GMT-02:00 Henri Roosen <henri.roosen@ginzinger.com>:
> Hi,
>
> Unfortunately commit-3ac72b7b63d5 "net: fec: align IP header in
> hardware" breaks networking on an iMX28 system.
>
> The commit seems valid for iMX6, where it is tested okay and solves the
> unaligned accesses.
>
> On iMX28 I still see unaligned accesses and networking is broken. Can
> anyone confirm this?

Does this fix the problem?

diff --git a/drivers/net/ethernet/freescale/fec_main.c
b/drivers/net/ethernet/freescale/fec_main.c
index 4ce8179..d1cefe1 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1430,14 +1430,15 @@ fec_enet_rx_queue(struct net_device *ndev, int
budget, u16 queue_id)
                skb_put(skb, pkt_len - 4);
                data = skb->data;

+               if (!is_copybreak && need_swap)
+                       swap_buffer(data, pkt_len);
+
+
 #if !defined(CONFIG_M5272)
                if (fep->quirks & FEC_QUIRK_HAS_RACC)
                        data = skb_pull_inline(skb, 2);
 #endif

-               if (!is_copybreak && need_swap)
-                       swap_buffer(data, pkt_len);
-
                /* Extract the enhanced buffer descriptor */
                ebdp = NULL;
                if (fep->bufdesc_ex)
