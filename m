From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH net-next] net: cleanup unused macros in net directory
Date: Fri, 14 Jan 2011 16:19:52 +0800
Message-ID: <4D300728.8030402@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, sjur.brandeland@stericsson.com,
	andy.grover@oracle.com, ericvh@gmail.com, jvrao@us.ibm.com,
	aneesh.kumar@linux.vnet.ibm.com, joe@perches.com,
	Chang
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57397 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756981Ab1ANI35 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jan 2011 03:29:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Clean up some unused macros in net/*.
1. be left for code change. e.g. PGV_FROM_VMALLOC, PGV_FROM_VMALLOC, KMEM_SAFETYZONE.
2. never be used since introduced to kernel.
   e.g. P9_RDMA_MAX_SGE, UTIL_CTRL_PKT_SIZE.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 net/9p/trans_rdma.c     |    1 -
 net/caif/cfcnfg.c       |    2 --
 net/caif/cfdgml.c       |    1 -
 net/caif/cfserl.c       |    1 -
 net/caif/cfutill.c      |    2 +-
 net/caif/cfveil.c       |    2 +-
 net/decnet/dn_table.c   |    1 -
 net/packet/af_packet.c  |    1 -
 net/rds/rds.h           |    1 -
 net/wanrouter/wanmain.c |    2 --
 10 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/net/9p/trans_rdma.c b/net/9p/trans_rdma.c
index 17c5ba7..29a54cc 100644
--- a/net/9p/trans_rdma.c
+++ b/net/9p/trans_rdma.c
@@ -59,7 +59,6 @@
 						 * safely advertise a maxsize
 						 * of 64k */
 
-#define P9_RDMA_MAX_SGE (P9_RDMA_MAXSIZE >> PAGE_SHIFT)
 /**
  * struct p9_trans_rdma - RDMA transport instance
  *
diff --git a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
index 21ede14..ed3cfda 100644
--- a/net/caif/cfcnfg.c
+++ b/net/caif/cfcnfg.c
@@ -23,10 +23,8 @@
 #include <asm/atomic.h>
 
 #define MAX_PHY_LAYERS 7
-#define PHY_NAME_LEN 20
 
 #define container_obj(layr) container_of(layr, struct cfcnfg, layer)
-#define RFM_FRAGMENT_SIZE 4030
 
 /* Information about CAIF physical interfaces held by Config Module in order
  * to manage physical interfaces
diff --git a/net/caif/cfdgml.c b/net/caif/cfdgml.c
index d3ed264..27dab26 100644
--- a/net/caif/cfdgml.c
+++ b/net/caif/cfdgml.c
@@ -18,7 +18,6 @@
 #define DGM_CMD_BIT  0x80
 #define DGM_FLOW_OFF 0x81
 #define DGM_FLOW_ON  0x80
-#define DGM_CTRL_PKT_SIZE 1
 #define DGM_MTU 1500
 
 static int cfdgml_receive(struct cflayer *layr, struct cfpkt *pkt);
diff --git a/net/caif/cfserl.c b/net/caif/cfserl.c
index 9297f7d..8303fe3 100644
--- a/net/caif/cfserl.c
+++ b/net/caif/cfserl.c
@@ -25,7 +25,6 @@ struct cfserl {
 	spinlock_t sync;
 	bool usestx;
 };
-#define STXLEN(layr) (layr->usestx ? 1 : 0)
 
 static int cfserl_receive(struct cflayer *layr, struct cfpkt *pkt);
 static int cfserl_transmit(struct cflayer *layr, struct cfpkt *pkt);
diff --git a/net/caif/cfutill.c b/net/caif/cfutill.c
index efad410..315c0d6 100644
--- a/net/caif/cfutill.c
+++ b/net/caif/cfutill.c
@@ -20,7 +20,7 @@
 #define UTIL_REMOTE_SHUTDOWN 0x82
 #define UTIL_FLOW_OFF 0x81
 #define UTIL_FLOW_ON  0x80
-#define UTIL_CTRL_PKT_SIZE 1
+
 static int cfutill_receive(struct cflayer *layr, struct cfpkt *pkt);
 static int cfutill_transmit(struct cflayer *layr, struct cfpkt *pkt);
 
diff --git a/net/caif/cfveil.c b/net/caif/cfveil.c
index 3b425b1..c3b1dec 100644
--- a/net/caif/cfveil.c
+++ b/net/caif/cfveil.c
@@ -17,7 +17,7 @@
 #define VEI_FLOW_OFF 0x81
 #define VEI_FLOW_ON  0x80
 #define VEI_SET_PIN  0x82
-#define VEI_CTRL_PKT_SIZE 1
+
 #define container_obj(layr) container_of(layr, struct cfsrvl, layer)
 
 static int cfvei_receive(struct cflayer *layr, struct cfpkt *pkt);
diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
index f2abd37..b66600b 100644
--- a/net/decnet/dn_table.c
+++ b/net/decnet/dn_table.c
@@ -59,7 +59,6 @@ struct dn_hash
 };
 
 #define dz_key_0(key)		((key).datum = 0)
-#define dz_prefix(key,dz)	((key).datum)
 
 #define for_nexthops(fi) { int nhsel; const struct dn_fib_nh *nh;\
 	for(nhsel = 0, nh = (fi)->fib_nh; nhsel < (fi)->fib_nhs; nh++, nhsel++)
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 91cb1d7..4b87237 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -164,7 +164,6 @@ struct packet_mreq_max {
 static int packet_set_ring(struct sock *sk, struct tpacket_req *req,
 		int closing, int tx_ring);
 
-#define PGV_FROM_VMALLOC 1
 struct pgv {
 	char *buffer;
 };
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 9542449..da8adac 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -50,7 +50,6 @@ rdsdebug(char *fmt, ...)
 #define RDS_FRAG_SIZE	((unsigned int)(1 << RDS_FRAG_SHIFT))
 
 #define RDS_CONG_MAP_BYTES	(65536 / 8)
-#define RDS_CONG_MAP_LONGS	(RDS_CONG_MAP_BYTES / sizeof(unsigned long))
 #define RDS_CONG_MAP_PAGES	(PAGE_ALIGN(RDS_CONG_MAP_BYTES) / PAGE_SIZE)
 #define RDS_CONG_MAP_PAGE_BITS	(PAGE_SIZE * 8)
 
diff --git a/net/wanrouter/wanmain.c b/net/wanrouter/wanmain.c
index 74944a2..788a12c 100644
--- a/net/wanrouter/wanmain.c
+++ b/net/wanrouter/wanmain.c
@@ -59,8 +59,6 @@
 #include <asm/uaccess.h>        /* copy_to/from_user */
 #include <linux/init.h>         /* __initfunc et al. */
 
-#define KMEM_SAFETYZONE 8
-
 #define DEV_TO_SLAVE(dev)	(*((struct net_device **)netdev_priv(dev)))
 
 /*
-- 
1.7.0.1
