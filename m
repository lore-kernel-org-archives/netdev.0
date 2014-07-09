From: Richard Weinberger <richard@nod.at>
Subject: [PATCH v3] hyperv: Add netpoll support
Date: Wed,  9 Jul 2014 16:23:59 +0200
Message-ID: <1404915839-15940-1-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, Richard Weinberger <richard@nod.at>,
 romieu@fr.zoreil.com, linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
 devel@linuxdriverproject.org
To: kys@microsoft.com,
	haiyangz@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

In order to have at least a netconsole to debug kernel issues on
Windows Azure this patch implements netpoll support.
Sending packets is easy, netvsc_start_xmit() does already everything
needed.

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 drivers/net/hyperv/netvsc_drv.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 4fd71b7..fcf3be7 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -736,6 +736,14 @@ static int netvsc_set_mac_addr(struct net_device *ndev, void *p)
 	return err;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void netvsc_poll_controller(struct net_device *net)
+{
+	/* As netvsc_start_xmit() works synchronous we don't have to
+	 * trigger anything here.
+	 */
+}
+#endif
 
 static const struct ethtool_ops ethtool_ops = {
 	.get_drvinfo	= netvsc_get_drvinfo,
@@ -751,6 +759,9 @@ static const struct net_device_ops device_ops = {
 	.ndo_validate_addr =		eth_validate_addr,
 	.ndo_set_mac_address =		netvsc_set_mac_addr,
 	.ndo_select_queue =		netvsc_select_queue,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller =		netvsc_poll_controller,
+#endif
 };
 
 /*
-- 
2.0.1
