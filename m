From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH][FIX 4.1] bgmac: fix requests for extra polling calls from NAPI
Date: Thu, 23 Apr 2015 20:56:29 +0200
Message-ID: <1429815389-17265-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>,
	Felix Fietkau <nbd@openwrt.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:34327 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030420AbbDWS4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 14:56:54 -0400
Received: by wicmx19 with SMTP id mx19so19106789wic.1
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2015 11:56:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After d75b1ade567f ("net: less interrupt masking in NAPI") polling
function has to return whole budget when it wants NAPI to call it again=
=2E

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
Cc: Felix Fietkau <nbd@openwrt.org>
=46ixes: eb64e2923a886 ("bgmac: leave interrupts disabled as long as th=
ere is work to do")
---
 drivers/net/ethernet/broadcom/bgmac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index de77d3a..21e3c38 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1260,7 +1260,7 @@ static int bgmac_poll(struct napi_struct *napi, i=
nt weight)
=20
 	/* Poll again if more events arrived in the meantime */
 	if (bgmac_read(bgmac, BGMAC_INT_STATUS) & (BGMAC_IS_TX0 | BGMAC_IS_RX=
))
-		return handled;
+		return weight;
=20
 	if (handled < weight) {
 		napi_complete(napi);
--=20
1.8.4.5
