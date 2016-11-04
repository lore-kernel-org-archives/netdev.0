From: Sebastian Frias <sf84@laposte.net>
Subject: [PATCH v2 1/2] net: ethernet: nb8800: Do not apply TX delay at MAC
 level
Date: Fri, 4 Nov 2016 19:18:46 +0100
Message-ID: <581CD106.2070109@laposte.net>
References: <581CD0CA.9070506@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, Mason <slash.tmp@free.fr>,
        Andrew Lunn <andrew@lunn.ch>
To: =?UTF-8?B?TcOlbnMgUnVsbGfDpXJk?= <mans@mansr.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpoutz26.laposte.net ([194.117.213.101]:52707 "EHLO
        smtp.laposte.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S938605AbcKDSSt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 14:18:49 -0400
Received: from smtp.laposte.net (localhost [127.0.0.1])
        by lpn-prd-vrout014 (Postfix) with ESMTP id D0FAF11F2AB
        for <netdev@vger.kernel.org>; Fri,  4 Nov 2016 19:18:47 +0100 (CET)
Received: from smtp.laposte.net (localhost [127.0.0.1])
        by lpn-prd-vrout014 (Postfix) with ESMTP id C4503121555
        for <netdev@vger.kernel.org>; Fri,  4 Nov 2016 19:18:47 +0100 (CET)
Received: from lpn-prd-vrin003 (lpn-prd-vrin003.prosodie [10.128.63.4])
        by lpn-prd-vrout014 (Postfix) with ESMTP id C170511F2AB
        for <netdev@vger.kernel.org>; Fri,  4 Nov 2016 19:18:47 +0100 (CET)
Received: from lpn-prd-vrin003 (localhost [127.0.0.1])
        by lpn-prd-vrin003 (Postfix) with ESMTP id A728F48E06D
        for <netdev@vger.kernel.org>; Fri,  4 Nov 2016 19:18:47 +0100 (CET)
In-Reply-To: <581CD0CA.9070506@laposte.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The delay can be applied at PHY or MAC level, but since
PHY drivers will apply the delay at PHY level when using
one of the "internal delay" declinations of RGMII mode
(like PHY_INTERFACE_MODE_RGMII_TXID), applying it again
at MAC level causes issues.

Signed-off-by: Sebastian Frias <sf84@laposte.net>
---
drivers/net/ethernet/aurora/nb8800.c | 2 +-
1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
index b59aa35..d2855c9 100644
--- a/drivers/net/ethernet/aurora/nb8800.c
+++ b/drivers/net/ethernet/aurora/nb8800.c
@@ -1282,7 +1282,7 @@ static int nb8800_tangox_init(struct net_device *dev)
break;

case PHY_INTERFACE_MODE_RGMII_TXID:
- pad_mode = PAD_MODE_RGMII | PAD_MODE_GTX_CLK_DELAY;
+ pad_mode = PAD_MODE_RGMII;
break;

default:
-- 
1.7.11.2
