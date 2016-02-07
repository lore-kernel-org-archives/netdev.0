From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH repost net-next] ethtool: future-proof interface for speed
 extensions
Date: Sun, 7 Feb 2016 23:27:55 +0200
Message-ID: <1454880301-20984-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Richard Cochran <richardcochran@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Hariprasad Shenai <hariprasad@chelsio.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Parav Pandit <parav.pandit@avagotech.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Many virtual and not quite virtual devices allow any speed to be set
through ethtool. In particular, this applies to the virtio-net devices.
Document this fact to make sure people don't assume the enum lists all
possible values.  Reserve values greater than INT_MAX for future
extension and to avoid conflict with SPEED_UNKNOWN.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

This is same as http://patchwork.ozlabs.org/patch/578911/
just reposting it separately so people notice.

This completes Nikolay Aleksandrov's recently merged
work on virtio-net ethtool support.

 include/uapi/linux/ethtool.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 57fa390..235e082 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -31,7 +31,7 @@
  *	physical connectors and other link features that are
  *	advertised through autonegotiation or enabled for
  *	auto-detection.
- * @speed: Low bits of the speed
+ * @speed: Low bits of the speed, 1Mb units, 0 to INT_MAX or SPEED_UNKNOWN
  * @duplex: Duplex mode; one of %DUPLEX_*
  * @port: Physical connector type; one of %PORT_*
  * @phy_address: MDIO address of PHY (transceiver); 0 or 255 if not
@@ -47,7 +47,7 @@
  *	obsoleted by &struct ethtool_coalesce.  Read-only; deprecated.
  * @maxrxpkt: Historically used to report RX IRQ coalescing; now
  *	obsoleted by &struct ethtool_coalesce.  Read-only; deprecated.
- * @speed_hi: High bits of the speed
+ * @speed_hi: High bits of the speed, 1Mb units, 0 to INT_MAX or SPEED_UNKNOWN
  * @eth_tp_mdix: Ethernet twisted-pair MDI(-X) status; one of
  *	%ETH_TP_MDI_*.  If the status is unknown or not applicable, the
  *	value will be %ETH_TP_MDI_INVALID.  Read-only.
@@ -1303,7 +1303,7 @@ enum ethtool_sfeatures_retval_bits {
  * it was forced up into this mode or autonegotiated.
  */
 
-/* The forced speed, 10Mb, 100Mb, gigabit, [2.5|5|10|20|25|40|50|56|100]GbE. */
+/* The forced speed, in units of 1Mb. All values 0 to INT_MAX are legal. */
 #define SPEED_10		10
 #define SPEED_100		100
 #define SPEED_1000		1000
-- 
MST
