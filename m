From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH 1/2] get_property returns const
Date: Fri, 27 Apr 2007 14:51:07 +1000
Message-ID: <20070427145107.4f73e436.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ppc-dev <linuxppc-dev@ozlabs.org>, akpm@linux-foundation.org,
	paulus@samba.org, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

This is left over from a previous cleanup of get_property.

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ehea/ehea_main.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

Jeff,

This patch is on top of your upstream branch from today. This change was
in Paulus' for-2.6.22 tree but has been reverted from there because of a
problematic clash with your tree.  This can be applied before or after
the other changes in Paulus' tree.

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index a36a023..ece9159 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -2519,14 +2519,14 @@ static int ehea_setup_ports(struct ehea_adapter *adapter)
 	struct device_node *lhea_dn;
 	struct device_node *eth_dn = NULL;
 
-	u32 *dn_log_port_id;
+	const u32 *dn_log_port_id;
 	int port_setup_ok = 0;
 	int i = 0;
 
 	lhea_dn = adapter->ebus_dev->ofdev.node;
 	while ((eth_dn = of_get_next_child(lhea_dn, eth_dn))) {
 
-		dn_log_port_id = (u32*)get_property(eth_dn, "ibm,hea-port-no",
+		dn_log_port_id = get_property(eth_dn, "ibm,hea-port-no",
 						    NULL);
 		if (!dn_log_port_id) {
 			ehea_error("bad device node: eth_dn name=%s",
@@ -2560,12 +2560,12 @@ static struct device_node *ehea_get_eth_dn(struct ehea_adapter *adapter,
 {
 	struct device_node *lhea_dn;
 	struct device_node *eth_dn = NULL;
-	u32 *dn_log_port_id;
+	const u32 *dn_log_port_id;
 
 	lhea_dn = adapter->ebus_dev->ofdev.node;
 	while ((eth_dn = of_get_next_child(lhea_dn, eth_dn))) {
 
-		dn_log_port_id = (u32*)get_property(eth_dn, "ibm,hea-port-no",
+		dn_log_port_id = get_property(eth_dn, "ibm,hea-port-no",
 						    NULL);
 		if (dn_log_port_id)
 			if (*dn_log_port_id == logical_port_id)
@@ -2680,7 +2680,7 @@ static int __devinit ehea_probe_adapter(struct ibmebus_dev *dev,
 					const struct of_device_id *id)
 {
 	struct ehea_adapter *adapter;
-	u64 *adapter_handle;
+	const u64 *adapter_handle;
 	int ret;
 
 	if (!dev || !dev->ofdev.node) {
@@ -2697,7 +2697,7 @@ static int __devinit ehea_probe_adapter(struct ibmebus_dev *dev,
 
 	adapter->ebus_dev = dev;
 
-	adapter_handle = (u64*)get_property(dev->ofdev.node, "ibm,hea-handle",
+	adapter_handle = get_property(dev->ofdev.node, "ibm,hea-handle",
 					    NULL);
 	if (adapter_handle)
 		adapter->handle = *adapter_handle;
-- 
1.5.1.2
