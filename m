From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH] ibmveth: use consistent types
Date: Tue, 6 Jan 2009 16:39:08 +1100
Message-ID: <20090106163908.2e6134f4.sfr@canb.auug.org.au>
References: <20081231140225.48b695ef.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ppc-dev <linuxppc-dev@ozlabs.org>,
	Santiago Leon <santil@us.ibm.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:45218 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750970AbZAFFjS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 00:39:18 -0500
In-Reply-To: <20081231140225.48b695ef.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These variables are only used with an interface that just dumps their
values into registers to be passed to the hypervisor. The arguments
to that interface are declared to be "unsigned long", so make these
variables match.  The macros are only used with these variables, so make
them match as well.

This code is currently only built for 64bit powerpc, so the transformation
is really a noop.  If the interface was ever ported to 32 bit, it would
almost certainly still use registers to pass the parameters and so
"unsigned long" would still be appropriate.

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ibmveth.c |    4 ++--
 drivers/net/ibmveth.h |   10 +++++-----
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index 9bc0f17..ca3bb9f 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -754,7 +754,7 @@ static int ibmveth_set_csum_offload(struct net_device *dev, u32 data,
 				    void (*done) (struct net_device *, u32))
 {
 	struct ibmveth_adapter *adapter = netdev_priv(dev);
-	u64 set_attr, clr_attr, ret_attr;
+	unsigned long set_attr, clr_attr, ret_attr;
 	long ret;
 	int rc1 = 0, rc2 = 0;
 	int restart = 0;
@@ -1209,7 +1209,7 @@ static int __devinit ibmveth_probe(struct vio_dev *dev, const struct vio_device_
 	long ret;
 	struct net_device *netdev;
 	struct ibmveth_adapter *adapter;
-	u64 set_attr, ret_attr;
+	unsigned long set_attr, ret_attr;
 
 	unsigned char *mac_addr_p;
 	unsigned int *mcastFilterSize_p;
diff --git a/drivers/net/ibmveth.h b/drivers/net/ibmveth.h
index d281869..ec76ace 100644
--- a/drivers/net/ibmveth.h
+++ b/drivers/net/ibmveth.h
@@ -39,11 +39,11 @@
 #define IbmVethMcastRemoveFilter     0x2UL
 #define IbmVethMcastClearFilterTable 0x3UL
 
-#define IBMVETH_ILLAN_PADDED_PKT_CSUM	0x0000000000002000ULL
-#define IBMVETH_ILLAN_TRUNK_PRI_MASK	0x0000000000000F00ULL
-#define IBMVETH_ILLAN_IPV6_TCP_CSUM		0x0000000000000004ULL
-#define IBMVETH_ILLAN_IPV4_TCP_CSUM		0x0000000000000002ULL
-#define IBMVETH_ILLAN_ACTIVE_TRUNK		0x0000000000000001ULL
+#define IBMVETH_ILLAN_PADDED_PKT_CSUM	0x0000000000002000UL
+#define IBMVETH_ILLAN_TRUNK_PRI_MASK	0x0000000000000F00UL
+#define IBMVETH_ILLAN_IPV6_TCP_CSUM		0x0000000000000004UL
+#define IBMVETH_ILLAN_IPV4_TCP_CSUM		0x0000000000000002UL
+#define IBMVETH_ILLAN_ACTIVE_TRUNK		0x0000000000000001UL
 
 /* hcall macros */
 #define h_register_logical_lan(ua, buflst, rxq, fltlst, mac) \
-- 
1.6.0.5

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
