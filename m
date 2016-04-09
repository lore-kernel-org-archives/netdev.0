From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: bcmgenet: use __napi_schedule_irqoff()
Date: Fri, 08 Apr 2016 22:30:56 -0700
Message-ID: <1460179856.6473.482.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1460178400.6473.469.camel@edumazet-glaptop3.roam.corp.google.com>
	 <5B66FA2B-6AAE-4FEB-B5FB-C5C9DF48FDB5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Petri Gynther <pgynther@google.com>, opendmb@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:36243 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114AbcDIFa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 01:30:59 -0400
Received: by mail-qg0-f42.google.com with SMTP id f52so107189070qga.3
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 22:30:59 -0700 (PDT)
In-Reply-To: <5B66FA2B-6AAE-4FEB-B5FB-C5C9DF48FDB5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>

bcmgenet_isr1() and bcmgenet_isr0() run in hard irq context,
we do not need to block irq again.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index f7b42b9fc979..4367d561a12e 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2493,7 +2493,7 @@ static irqreturn_t bcmgenet_isr1(int irq, void *dev_id)
 
 		if (likely(napi_schedule_prep(&rx_ring->napi))) {
 			rx_ring->int_disable(rx_ring);
-			__napi_schedule(&rx_ring->napi);
+			__napi_schedule_irqoff(&rx_ring->napi);
 		}
 	}
 
@@ -2506,7 +2506,7 @@ static irqreturn_t bcmgenet_isr1(int irq, void *dev_id)
 
 		if (likely(napi_schedule_prep(&tx_ring->napi))) {
 			tx_ring->int_disable(tx_ring);
-			__napi_schedule(&tx_ring->napi);
+			__napi_schedule_irqoff(&tx_ring->napi);
 		}
 	}
 
@@ -2536,7 +2536,7 @@ static irqreturn_t bcmgenet_isr0(int irq, void *dev_id)
 
 		if (likely(napi_schedule_prep(&rx_ring->napi))) {
 			rx_ring->int_disable(rx_ring);
-			__napi_schedule(&rx_ring->napi);
+			__napi_schedule_irqoff(&rx_ring->napi);
 		}
 	}
 
@@ -2545,7 +2545,7 @@ static irqreturn_t bcmgenet_isr0(int irq, void *dev_id)
 
 		if (likely(napi_schedule_prep(&tx_ring->napi))) {
 			tx_ring->int_disable(tx_ring);
-			__napi_schedule(&tx_ring->napi);
+			__napi_schedule_irqoff(&tx_ring->napi);
 		}
 	}
 
