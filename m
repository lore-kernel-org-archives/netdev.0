From: Yegor Yefremov <yegor_sub1@visionsystems.de>
Subject: [PATCH][KS8695] Mark network interface as running on ifconfig up
Date: Thu, 11 Feb 2010 12:12:43 +0100
Message-ID: <4B73E62B.3030305@visionsystems.de>
Reply-To: yegor_sub1@visionsystems.de
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Victor <avictor.za@gmail.com>
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

[KS8695] Mark network interface as running on ifconfig up

Without netif_carrier_on() network interface will not transmit any packets
after ifconfig down and subsequent ifconfig up.

Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>

Index: linux-2.6.33-rc7/drivers/net/arm/ks8695net.c
===================================================================
--- linux-2.6.33-rc7.orig/drivers/net/arm/ks8695net.c
+++ linux-2.6.33-rc7/drivers/net/arm/ks8695net.c
@@ -1371,6 +1371,7 @@ ks8695_open(struct net_device *ndev)
 
 	napi_enable(&ksp->napi);
 	netif_start_queue(ndev);
+	netif_carrier_on(ndev);
 
 	return 0;
 }
