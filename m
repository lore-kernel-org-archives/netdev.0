From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH] Cleanup include/net/tcp.h include-files and coding-style
Date: Sun,  9 Jan 2011 21:55:34 +0100
Message-ID: <1294606534-28522-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Christoph Paasch <christoph.paasch@uclouvain.be>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:54768 "EHLO
	smtp3.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055Ab1AIU4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jan 2011 15:56:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch reviews the include-files of net/tcp.h
Several #include where redundant. Some where not directly needed by
net/tcp.h

Files, including net/tcp.h where also including some the *.h-files that
net/tcp.h is already including. Thus, in these files the inclusion of
the *.h file is unnecessary.

Redundant includes in net/tcp.h:

linux/list.h --- included by linux/textsearch.h which is included by
                 linux/skbuff.h
linux/slab.h --- included by linux/crypto.h
linux/cache.h --- included by linux/skbuff.h
linux/skbuff.h --- included by net/sock.h
linux/kref.h --- included by linux/kobject.h, which is  included by
                 linux/device.h, which is included by
                 linux/dmaengine.h, which is included by
                 linux/skbuff.h
net/inet_connection_sock.h --- included by net/inet_hashtables.h
net/checksum.h --- included by net/sock.h
net/request_sock.h --- included by net/inet_connection_sock.h
net/sock.h --- included by net/request_sock.h
net/snmp.h --- included by net/ip.h
net/dst.h --- included by net/sock.h
linux/seq_file.h --- included by net/neighbour.h, which is included by
                     net/dst.h

Include-files not directly needed by net/tcp.h:

linux/percpu.h
linux/dmaengine.h
net/tcp_states.h
net/inet_ecn.h

Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 drivers/block/drbd/drbd_int.h          |    4 ---
 drivers/dma/ioat/dma.h                 |    1 -
 drivers/dma/iovlock.c                  |    1 -
 drivers/infiniband/core/cma.c          |    1 -
 drivers/infiniband/hw/nes/nes_cm.c     |    4 ---
 drivers/infiniband/hw/nes/nes_nic.c    |    2 -
 drivers/net/benet/be.h                 |    2 -
 drivers/net/bna/bnad.h                 |    1 -
 drivers/net/bnx2.c                     |    5 ----
 drivers/net/bnx2x/bnx2x_main.c         |    4 ---
 drivers/net/cnic.c                     |    3 --
 drivers/net/cxgb3/cxgb3_defs.h         |    1 -
 drivers/net/cxgb4/sge.c                |    1 -
 drivers/net/cxgb4vf/sge.c              |    1 -
 drivers/net/myri10ge/myri10ge.c        |    5 ----
 drivers/net/pch_gbe/pch_gbe.h          |    1 -
 drivers/net/s2io.c                     |    3 --
 drivers/net/slhc.c                     |    5 ----
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c     |    1 -
 drivers/scsi/cxgbi/libcxgbi.c          |    3 --
 drivers/scsi/iscsi_tcp.c               |    2 -
 drivers/scsi/libiscsi.c                |    1 -
 drivers/scsi/libiscsi_tcp.c            |    3 --
 drivers/scsi/qla4xxx/ql4_def.h         |    2 -
 drivers/scsi/scsi_transport_iscsi.c    |    1 -
 fs/dlm/lowcomms.c                      |    2 -
 fs/ocfs2/cluster/tcp.c                 |    2 -
 include/linux/inet_lro.h               |    1 -
 include/net/netfilter/nf_tproxy_core.h |    3 --
 include/net/tcp.h                      |   40 ++++++++------------------------
 net/ceph/messenger.c                   |    1 -
 net/core/netpoll.c                     |    1 -
 net/core/sock.c                        |    6 ----
 net/dccp/dccp.h                        |    2 -
 net/dccp/ipv6.c                        |    1 +
 net/ipv4/af_inet.c                     |    6 ----
 net/ipv4/arp.c                         |    5 ----
 net/ipv4/cipso_ipv4.c                  |    3 --
 net/ipv4/fib_frontend.c                |    5 ----
 net/ipv4/fib_hash.c                    |    4 ---
 net/ipv4/fib_rules.c                   |    2 -
 net/ipv4/fib_semantics.c               |    4 ---
 net/ipv4/fib_trie.c                    |    5 ----
 net/ipv4/icmp.c                        |    6 ----
 net/ipv4/inet_diag.c                   |    5 ----
 net/ipv4/inet_lro.c                    |    2 +
 net/ipv4/ip_forward.c                  |    6 ----
 net/ipv4/ip_input.c                    |    1 -
 net/ipv4/netfilter/ipt_LOG.c           |    1 -
 net/ipv4/netfilter/ipt_REJECT.c        |    4 ---
 net/ipv4/netfilter/nf_nat_core.c       |    3 --
 net/ipv4/netfilter/nf_nat_h323.c       |    1 -
 net/ipv4/netfilter/nf_nat_helper.c     |    3 --
 net/ipv4/proc.c                        |    2 -
 net/ipv4/route.c                       |    5 ----
 net/ipv4/syncookies.c                  |    3 --
 net/ipv4/sysctl_net_ipv4.c             |    3 --
 net/ipv4/tcp.c                         |    6 ----
 net/ipv4/tcp_cong.c                    |    1 -
 net/ipv4/tcp_diag.c                    |    2 -
 net/ipv4/tcp_illinois.c                |    1 -
 net/ipv4/tcp_input.c                   |    3 +-
 net/ipv4/tcp_ipv4.c                    |    5 ----
 net/ipv4/tcp_minisocks.c               |    1 -
 net/ipv4/tcp_output.c                  |    1 +
 net/ipv4/tcp_probe.c                   |    2 -
 net/ipv4/tcp_vegas.c                   |    1 -
 net/ipv4/tcp_veno.c                    |    1 -
 net/ipv4/tcp_westwood.c                |    1 -
 net/ipv4/tcp_yeah.c                    |    1 -
 net/ipv6/addrconf.c                    |    5 ----
 net/ipv6/af_inet6.c                    |    2 -
 net/ipv6/ipv6_sockglue.c               |    3 --
 net/ipv6/netfilter/ip6t_LOG.c          |    1 -
 net/ipv6/netfilter/ip6t_REJECT.c       |    1 -
 net/ipv6/proc.c                        |    3 --
 net/ipv6/route.c                       |    4 ---
 net/ipv6/syncookies.c                  |    2 -
 net/ipv6/tcp_ipv6.c                    |    4 ---
 net/netfilter/ipvs/ip_vs_app.c         |    3 --
 net/netfilter/ipvs/ip_vs_core.c        |    3 --
 net/netfilter/ipvs/ip_vs_ftp.c         |    1 -
 net/netfilter/ipvs/ip_vs_proto.c       |    1 -
 net/netfilter/ipvs/ip_vs_proto_tcp.c   |    2 -
 net/netfilter/ipvs/ip_vs_xmit.c        |    3 --
 net/netfilter/nf_conntrack_ftp.c       |    2 -
 net/netfilter/nf_conntrack_proto_tcp.c |    2 -
 net/netfilter/xt_TCPMSS.c              |    3 --
 net/netfilter/xt_TCPOPTSTRIP.c         |    2 -
 net/netfilter/xt_osf.c                 |    5 ----
 net/netfilter/xt_socket.c              |    2 -
 net/netfilter/xt_tcpmss.c              |    1 -
 net/netfilter/xt_tcpudp.c              |    1 -
 net/rds/tcp.c                          |    1 -
 net/rds/tcp_recv.c                     |    1 -
 net/sched/act_csum.c                   |    3 --
 net/sched/act_nat.c                    |    3 --
 net/sunrpc/svcsock.c                   |    6 ----
 net/sunrpc/xprtsock.c                  |    4 ---
 security/selinux/hooks.c               |    3 --
 100 files changed, 15 insertions(+), 284 deletions(-)

diff --git a/drivers/block/drbd/drbd_int.h b/drivers/block/drbd/drbd_int.h
index 1ea1a34..e947b2d 100644
--- a/drivers/block/drbd/drbd_int.h
+++ b/drivers/block/drbd/drbd_int.h
@@ -29,13 +29,9 @@
 #include <linux/compiler.h>
 #include <linux/types.h>
 #include <linux/version.h>
-#include <linux/list.h>
 #include <linux/sched.h>
 #include <linux/bitops.h>
-#include <linux/slab.h>
-#include <linux/crypto.h>
 #include <linux/ratelimit.h>
-#include <linux/tcp.h>
 #include <linux/mutex.h>
 #include <linux/major.h>
 #include <linux/blkdev.h>
diff --git a/drivers/dma/ioat/dma.h b/drivers/dma/ioat/dma.h
index 5216c8a..ea07750 100644
--- a/drivers/dma/ioat/dma.h
+++ b/drivers/dma/ioat/dma.h
@@ -26,7 +26,6 @@
 #include "registers.h"
 #include <linux/init.h>
 #include <linux/dmapool.h>
-#include <linux/cache.h>
 #include <linux/pci_ids.h>
 #include <net/tcp.h>
 
diff --git a/drivers/dma/iovlock.c b/drivers/dma/iovlock.c
index bb48a57..c0a272c 100644
--- a/drivers/dma/iovlock.c
+++ b/drivers/dma/iovlock.c
@@ -27,7 +27,6 @@
 
 #include <linux/dmaengine.h>
 #include <linux/pagemap.h>
-#include <linux/slab.h>
 #include <net/tcp.h> /* for memcpy_toiovec */
 #include <asm/io.h>
 #include <asm/uaccess.h>
diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 6884da2..7475b09 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -40,7 +40,6 @@
 #include <linux/random.h>
 #include <linux/idr.h>
 #include <linux/inetdevice.h>
-#include <linux/slab.h>
 
 #include <net/tcp.h>
 #include <net/ipv6.h>
diff --git a/drivers/infiniband/hw/nes/nes_cm.c b/drivers/infiniband/hw/nes/nes_cm.c
index 25ad0f9..2518bf2 100644
--- a/drivers/infiniband/hw/nes/nes_cm.c
+++ b/drivers/infiniband/hw/nes/nes_cm.c
@@ -35,9 +35,7 @@
 #define TCPOPT_TIMESTAMP 8
 
 #include <asm/atomic.h>
-#include <linux/skbuff.h>
 #include <linux/ip.h>
-#include <linux/tcp.h>
 #include <linux/init.h>
 #include <linux/if_arp.h>
 #include <linux/if_vlan.h>
@@ -50,10 +48,8 @@
 #include <linux/etherdevice.h>
 #include <linux/netdevice.h>
 #include <linux/random.h>
-#include <linux/list.h>
 #include <linux/threads.h>
 #include <linux/highmem.h>
-#include <linux/slab.h>
 #include <net/arp.h>
 #include <net/neighbour.h>
 #include <net/route.h>
diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
index 3892e2c..8d2a43b 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -36,11 +36,9 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ip.h>
-#include <linux/tcp.h>
 #include <linux/if_arp.h>
 #include <linux/if_vlan.h>
 #include <linux/ethtool.h>
-#include <linux/slab.h>
 #include <net/tcp.h>
 
 #include <net/inet_common.h>
diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index d64313b..f0df37c 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -23,13 +23,11 @@
 #include <linux/version.h>
 #include <linux/delay.h>
 #include <net/tcp.h>
-#include <net/ip.h>
 #include <net/ipv6.h>
 #include <linux/if_vlan.h>
 #include <linux/workqueue.h>
 #include <linux/interrupt.h>
 #include <linux/firmware.h>
-#include <linux/slab.h>
 
 #include "be_hw.h"
 
diff --git a/drivers/net/bna/bnad.h b/drivers/net/bna/bnad.h
index ebc3a90..30fdc90 100644
--- a/drivers/net/bna/bnad.h
+++ b/drivers/net/bna/bnad.h
@@ -29,7 +29,6 @@
 #include <asm/checksum.h>
 #include <net/ip6_checksum.h>
 
-#include <net/ip.h>
 #include <net/tcp.h>
 
 #include "bna.h"
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 062600b..51625b9 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -18,14 +18,12 @@
 #include <linux/timer.h>
 #include <linux/errno.h>
 #include <linux/ioport.h>
-#include <linux/slab.h>
 #include <linux/vmalloc.h>
 #include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
-#include <linux/skbuff.h>
 #include <linux/dma-mapping.h>
 #include <linux/bitops.h>
 #include <asm/io.h>
@@ -37,13 +35,10 @@
 #include <linux/ethtool.h>
 #include <linux/mii.h>
 #include <linux/if_vlan.h>
-#include <net/ip.h>
 #include <net/tcp.h>
-#include <net/checksum.h>
 #include <linux/workqueue.h>
 #include <linux/crc32.h>
 #include <linux/prefetch.h>
-#include <linux/cache.h>
 #include <linux/firmware.h>
 #include <linux/log2.h>
 #include <linux/aer.h>
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 9709b85..5d87318 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -22,13 +22,11 @@
 #include <linux/timer.h>
 #include <linux/errno.h>
 #include <linux/ioport.h>
-#include <linux/slab.h>
 #include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
-#include <linux/skbuff.h>
 #include <linux/dma-mapping.h>
 #include <linux/bitops.h>
 #include <linux/irq.h>
@@ -38,9 +36,7 @@
 #include <linux/ethtool.h>
 #include <linux/mii.h>
 #include <linux/if_vlan.h>
-#include <net/ip.h>
 #include <net/tcp.h>
-#include <net/checksum.h>
 #include <net/ip6_checksum.h>
 #include <linux/workqueue.h>
 #include <linux/crc32.h>
diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 6dff321..3f47a8a 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -16,8 +16,6 @@
 
 #include <linux/kernel.h>
 #include <linux/errno.h>
-#include <linux/list.h>
-#include <linux/slab.h>
 #include <linux/pci.h>
 #include <linux/init.h>
 #include <linux/netdevice.h>
@@ -30,7 +28,6 @@
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 #define BCM_VLAN 1
 #endif
-#include <net/ip.h>
 #include <net/tcp.h>
 #include <net/route.h>
 #include <net/ipv6.h>
diff --git a/drivers/net/cxgb3/cxgb3_defs.h b/drivers/net/cxgb3/cxgb3_defs.h
index 920d918..fd1c520 100644
--- a/drivers/net/cxgb3/cxgb3_defs.h
+++ b/drivers/net/cxgb3/cxgb3_defs.h
@@ -32,7 +32,6 @@
 #ifndef _CHELSIO_DEFS_H
 #define _CHELSIO_DEFS_H
 
-#include <linux/skbuff.h>
 #include <net/tcp.h>
 
 #include "t3cdev.h"
diff --git a/drivers/net/cxgb4/sge.c b/drivers/net/cxgb4/sge.c
index 1702225..ca0f062 100644
--- a/drivers/net/cxgb4/sge.c
+++ b/drivers/net/cxgb4/sge.c
@@ -32,7 +32,6 @@
  * SOFTWARE.
  */
 
-#include <linux/skbuff.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/if_vlan.h>
diff --git a/drivers/net/cxgb4vf/sge.c b/drivers/net/cxgb4vf/sge.c
index ecf0770..d051a5f 100644
--- a/drivers/net/cxgb4vf/sge.c
+++ b/drivers/net/cxgb4vf/sge.c
@@ -33,7 +33,6 @@
  * SOFTWARE.
  */
 
-#include <linux/skbuff.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/if_vlan.h>
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 8524cc4..5677677 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -40,9 +40,7 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
-#include <linux/tcp.h>
 #include <linux/netdevice.h>
-#include <linux/skbuff.h>
 #include <linux/string.h>
 #include <linux/module.h>
 #include <linux/pci.h>
@@ -64,9 +62,6 @@
 #include <linux/moduleparam.h>
 #include <linux/io.h>
 #include <linux/log2.h>
-#include <linux/slab.h>
-#include <net/checksum.h>
-#include <net/ip.h>
 #include <net/tcp.h>
 #include <asm/byteorder.h>
 #include <asm/io.h>
diff --git a/drivers/net/pch_gbe/pch_gbe.h b/drivers/net/pch_gbe/pch_gbe.h
index a0c26a9..264088a 100644
--- a/drivers/net/pch_gbe/pch_gbe.h
+++ b/drivers/net/pch_gbe/pch_gbe.h
@@ -30,7 +30,6 @@
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/vmalloc.h>
-#include <net/ip.h>
 #include <net/tcp.h>
 #include <net/udp.h>
 
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index ecc25aa..f0e243f 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -64,7 +64,6 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/mdio.h>
-#include <linux/skbuff.h>
 #include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/stddef.h>
@@ -74,10 +73,8 @@
 #include <linux/workqueue.h>
 #include <linux/if_vlan.h>
 #include <linux/ip.h>
-#include <linux/tcp.h>
 #include <linux/uaccess.h>
 #include <linux/io.h>
-#include <linux/slab.h>
 #include <net/tcp.h>
 
 #include <asm/system.h>
diff --git a/drivers/net/slhc.c b/drivers/net/slhc.c
index ab9e3b7..869d0bc 100644
--- a/drivers/net/slhc.c
+++ b/drivers/net/slhc.c
@@ -51,7 +51,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/slab.h>
 #include <linux/types.h>
 #include <linux/string.h>
 #include <linux/errno.h>
@@ -68,16 +67,12 @@
 #include <linux/fcntl.h>
 #include <linux/inet.h>
 #include <linux/netdevice.h>
-#include <net/ip.h>
 #include <net/protocol.h>
 #include <net/icmp.h>
 #include <net/tcp.h>
-#include <linux/skbuff.h>
-#include <net/sock.h>
 #include <linux/timer.h>
 #include <asm/system.h>
 #include <asm/uaccess.h>
-#include <net/checksum.h>
 #include <asm/unaligned.h>
 
 static unsigned char *encode(unsigned char *cp, unsigned short n);
diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index 8c04fad..8b95399 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -18,7 +18,6 @@
 #include <linux/moduleparam.h>
 #include <scsi/scsi_host.h>
 #include <net/tcp.h>
-#include <net/dst.h>
 #include <linux/netdevice.h>
 
 #include "t4_msg.h"
diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index be56617..f3ca6b2 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -13,8 +13,6 @@
 
 #define pr_fmt(fmt)	KBUILD_MODNAME ":%s: " fmt, __func__
 
-#include <linux/skbuff.h>
-#include <linux/crypto.h>
 #include <linux/scatterlist.h>
 #include <linux/pci.h>
 #include <scsi/scsi.h>
@@ -22,7 +20,6 @@
 #include <scsi/scsi_host.h>
 #include <linux/if_vlan.h>
 #include <linux/inet.h>
-#include <net/dst.h>
 #include <net/route.h>
 #include <linux/inetdevice.h>	/* ip_dev_find */
 #include <net/tcp.h>
diff --git a/drivers/scsi/iscsi_tcp.c b/drivers/scsi/iscsi_tcp.c
index fec47de..48a10ac 100644
--- a/drivers/scsi/iscsi_tcp.c
+++ b/drivers/scsi/iscsi_tcp.c
@@ -28,10 +28,8 @@
 
 #include <linux/types.h>
 #include <linux/inet.h>
-#include <linux/slab.h>
 #include <linux/file.h>
 #include <linux/blkdev.h>
-#include <linux/crypto.h>
 #include <linux/delay.h>
 #include <linux/kfifo.h>
 #include <linux/scatterlist.h>
diff --git a/drivers/scsi/libiscsi.c b/drivers/scsi/libiscsi.c
index c15fde8..90bef29 100644
--- a/drivers/scsi/libiscsi.c
+++ b/drivers/scsi/libiscsi.c
@@ -25,7 +25,6 @@
 #include <linux/kfifo.h>
 #include <linux/delay.h>
 #include <linux/log2.h>
-#include <linux/slab.h>
 #include <asm/unaligned.h>
 #include <net/tcp.h>
 #include <scsi/scsi_cmnd.h>
diff --git a/drivers/scsi/libiscsi_tcp.c b/drivers/scsi/libiscsi_tcp.c
index 8eeb39f..946dff5 100644
--- a/drivers/scsi/libiscsi_tcp.c
+++ b/drivers/scsi/libiscsi_tcp.c
@@ -27,12 +27,9 @@
  */
 
 #include <linux/types.h>
-#include <linux/list.h>
 #include <linux/inet.h>
-#include <linux/slab.h>
 #include <linux/file.h>
 #include <linux/blkdev.h>
-#include <linux/crypto.h>
 #include <linux/delay.h>
 #include <linux/kfifo.h>
 #include <linux/scatterlist.h>
diff --git a/drivers/scsi/qla4xxx/ql4_def.h b/drivers/scsi/qla4xxx/ql4_def.h
index 0f3bfc3..5b6a212 100644
--- a/drivers/scsi/qla4xxx/ql4_def.h
+++ b/drivers/scsi/qla4xxx/ql4_def.h
@@ -12,11 +12,9 @@
 #include <linux/init.h>
 #include <linux/types.h>
 #include <linux/module.h>
-#include <linux/list.h>
 #include <linux/pci.h>
 #include <linux/dma-mapping.h>
 #include <linux/sched.h>
-#include <linux/slab.h>
 #include <linux/dmapool.h>
 #include <linux/mempool.h>
 #include <linux/spinlock.h>
diff --git a/drivers/scsi/scsi_transport_iscsi.c b/drivers/scsi/scsi_transport_iscsi.c
index 332387a..b1d1e62 100644
--- a/drivers/scsi/scsi_transport_iscsi.c
+++ b/drivers/scsi/scsi_transport_iscsi.c
@@ -22,7 +22,6 @@
  */
 #include <linux/module.h>
 #include <linux/mutex.h>
-#include <linux/slab.h>
 #include <net/tcp.h>
 #include <scsi/scsi.h>
 #include <scsi/scsi_host.h>
diff --git a/fs/dlm/lowcomms.c b/fs/dlm/lowcomms.c
index 37a34c2..afb84f5 100644
--- a/fs/dlm/lowcomms.c
+++ b/fs/dlm/lowcomms.c
@@ -45,13 +45,11 @@
  */
 
 #include <asm/ioctls.h>
-#include <net/sock.h>
 #include <net/tcp.h>
 #include <linux/pagemap.h>
 #include <linux/file.h>
 #include <linux/mutex.h>
 #include <linux/sctp.h>
-#include <linux/slab.h>
 #include <net/sctp/user.h>
 #include <net/ipv6.h>
 
diff --git a/fs/ocfs2/cluster/tcp.c b/fs/ocfs2/cluster/tcp.c
index 9aa426e..be7979b 100644
--- a/fs/ocfs2/cluster/tcp.c
+++ b/fs/ocfs2/cluster/tcp.c
@@ -55,9 +55,7 @@
 
 #include <linux/kernel.h>
 #include <linux/jiffies.h>
-#include <linux/slab.h>
 #include <linux/idr.h>
-#include <linux/kref.h>
 #include <linux/net.h>
 #include <net/tcp.h>
 
diff --git a/include/linux/inet_lro.h b/include/linux/inet_lro.h
index c4335fa..62ebac7 100644
--- a/include/linux/inet_lro.h
+++ b/include/linux/inet_lro.h
@@ -28,7 +28,6 @@
 #ifndef __INET_LRO_H_
 #define __INET_LRO_H_
 
-#include <net/ip.h>
 #include <net/tcp.h>
 
 /*
diff --git a/include/net/netfilter/nf_tproxy_core.h b/include/net/netfilter/nf_tproxy_core.h
index cd85b3b..e8ea472 100644
--- a/include/net/netfilter/nf_tproxy_core.h
+++ b/include/net/netfilter/nf_tproxy_core.h
@@ -3,9 +3,6 @@
 
 #include <linux/types.h>
 #include <linux/in.h>
-#include <linux/skbuff.h>
-#include <net/sock.h>
-#include <net/inet_hashtables.h>
 #include <net/inet6_hashtables.h>
 #include <net/tcp.h>
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index e36c874..5bd3122 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -21,30 +21,13 @@
 #define TCP_DEBUG 1
 #define FASTRETRANS_DEBUG 1
 
-#include <linux/list.h>
 #include <linux/tcp.h>
-#include <linux/slab.h>
-#include <linux/cache.h>
-#include <linux/percpu.h>
-#include <linux/skbuff.h>
-#include <linux/dmaengine.h>
 #include <linux/crypto.h>
 #include <linux/cryptohash.h>
-#include <linux/kref.h>
 
-#include <net/inet_connection_sock.h>
 #include <net/inet_timewait_sock.h>
 #include <net/inet_hashtables.h>
-#include <net/checksum.h>
-#include <net/request_sock.h>
-#include <net/sock.h>
-#include <net/snmp.h>
 #include <net/ip.h>
-#include <net/tcp_states.h>
-#include <net/inet_ecn.h>
-#include <net/dst.h>
-
-#include <linux/seq_file.h>
 
 extern struct inet_hashinfo tcp_hashinfo;
 
@@ -258,7 +241,7 @@ extern int tcp_memory_pressure;
 
 static inline int before(__u32 seq1, __u32 seq2)
 {
-        return (__s32)(seq1-seq2) < 0;
+        return (__s32) (seq1 - seq2) < 0;
 }
 #define after(seq2, seq1) 	before(seq1, seq2)
 
@@ -421,7 +404,7 @@ extern int tcp_disconnect(struct sock *sk, int flags);
 
 
 /* From syncookies.c */
-extern __u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
+extern __u32 syncookie_secret[2][16 - 4 + SHA_DIGEST_WORDS];
 extern struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb, 
 				    struct ip_options *opt);
 extern __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, 
@@ -498,7 +481,7 @@ extern void tcp_get_info(struct sock *, struct tcp_info *);
 
 /* Read 'sendfile()'-style from a TCP socket */
 typedef int (*sk_read_actor_t)(read_descriptor_t *, struct sk_buff *,
-				unsigned int, size_t);
+			       unsigned int, size_t);
 extern int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 			 sk_read_actor_t recv_actor);
 
@@ -578,9 +561,9 @@ extern u32 __tcp_select_window(struct sock *sk);
  * to use only the low 32-bits of jiffies and hide the ugly
  * casts with the following macro.
  */
-#define tcp_time_stamp		((__u32)(jiffies))
+#define tcp_time_stamp		((__u32) (jiffies))
 
-#define tcp_flag_byte(th) (((u_int8_t *)th)[13])
+#define tcp_flag_byte(th) (((u_int8_t *) th)[13])
 
 #define TCPHDR_FIN 0x01
 #define TCPHDR_SYN 0x02
@@ -620,7 +603,7 @@ struct tcp_skb_cb {
 	__u32		ack_seq;	/* Sequence number ACK'd	*/
 };
 
-#define TCP_SKB_CB(__skb)	((struct tcp_skb_cb *)&((__skb)->cb[0]))
+#define TCP_SKB_CB(__skb)	((struct tcp_skb_cb *) &((__skb)->cb[0]))
 
 /* Due to TSO, an SKB can be composed of multiple actual
  * packets.  To keep these tracked properly, we use this.
@@ -962,9 +945,9 @@ extern void tcp_select_initial_window(int __space, __u32 mss,
 
 static inline int tcp_win_from_space(int space)
 {
-	return sysctl_tcp_adv_win_scale<=0 ?
-		(space>>(-sysctl_tcp_adv_win_scale)) :
-		space - (space>>sysctl_tcp_adv_win_scale);
+	return sysctl_tcp_adv_win_scale <= 0 ?
+		(space >> (- sysctl_tcp_adv_win_scale)) :
+		space - (space >> sysctl_tcp_adv_win_scale);
 }
 
 /* Note: caller must be prepared to deal with negative returns */ 
@@ -1094,9 +1077,6 @@ static inline void tcp_clear_all_retrans_hints(struct tcp_sock *tp)
 	tp->retransmit_skb_hint = NULL;
 }
 
-/* MD5 Signature */
-struct crypto_hash;
-
 /* - key database */
 struct tcp_md5sig_key {
 	u8			*key;
@@ -1529,7 +1509,7 @@ struct tcp_extend_values {
 
 static inline struct tcp_extend_values *tcp_xv(struct request_values *rvp)
 {
-	return (struct tcp_extend_values *)rvp;
+	return (struct tcp_extend_values *) rvp;
 }
 
 extern void tcp_v4_init(void);
diff --git a/net/ceph/messenger.c b/net/ceph/messenger.c
index b6ff4a1..480f82e 100644
--- a/net/ceph/messenger.c
+++ b/net/ceph/messenger.c
@@ -6,7 +6,6 @@
 #include <linux/inet.h>
 #include <linux/kthread.h>
 #include <linux/net.h>
-#include <linux/slab.h>
 #include <linux/socket.h>
 #include <linux/string.h>
 #include <linux/bio.h>
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 4e98ffa..30b1d37 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -22,7 +22,6 @@
 #include <linux/delay.h>
 #include <linux/rcupdate.h>
 #include <linux/workqueue.h>
-#include <linux/slab.h>
 #include <net/tcp.h>
 #include <net/udp.h>
 #include <asm/unaligned.h>
diff --git a/net/core/sock.c b/net/core/sock.c
index e5af8d5..71634cb 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -97,17 +97,14 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/proc_fs.h>
-#include <linux/seq_file.h>
 #include <linux/sched.h>
 #include <linux/timer.h>
 #include <linux/string.h>
 #include <linux/sockios.h>
 #include <linux/net.h>
 #include <linux/mm.h>
-#include <linux/slab.h>
 #include <linux/interrupt.h>
 #include <linux/poll.h>
-#include <linux/tcp.h>
 #include <linux/init.h>
 #include <linux/highmem.h>
 #include <linux/user_namespace.h>
@@ -117,10 +114,7 @@
 
 #include <linux/netdevice.h>
 #include <net/protocol.h>
-#include <linux/skbuff.h>
 #include <net/net_namespace.h>
-#include <net/request_sock.h>
-#include <net/sock.h>
 #include <linux/net_tstamp.h>
 #include <net/xfrm.h>
 #include <linux/ipsec.h>
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index a8ed459..d5f8b9e 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -14,8 +14,6 @@
 
 #include <linux/dccp.h>
 #include <linux/ktime.h>
-#include <net/snmp.h>
-#include <net/sock.h>
 #include <net/tcp.h>
 #include "ackvec.h"
 
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index dca711d..9930e1a 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -23,6 +23,7 @@
 #include <net/inet_sock.h>
 #include <net/inet6_connection_sock.h>
 #include <net/inet6_hashtables.h>
+#include <net/inet_ecn.h>
 #include <net/ip6_route.h>
 #include <net/ipv6.h>
 #include <net/protocol.h>
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index f581f77..f1cff70 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -86,7 +86,6 @@
 #include <linux/poll.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/random.h>
-#include <linux/slab.h>
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
@@ -95,18 +94,13 @@
 #include <linux/igmp.h>
 #include <linux/inetdevice.h>
 #include <linux/netdevice.h>
-#include <net/checksum.h>
-#include <net/ip.h>
 #include <net/protocol.h>
 #include <net/arp.h>
 #include <net/route.h>
 #include <net/ip_fib.h>
-#include <net/inet_connection_sock.h>
 #include <net/tcp.h>
 #include <net/udp.h>
 #include <net/udplite.h>
-#include <linux/skbuff.h>
-#include <net/sock.h>
 #include <net/raw.h>
 #include <net/icmp.h>
 #include <net/ipip.h>
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index d8e540c..ec29d0a 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -90,26 +90,21 @@
 #include <linux/fddidevice.h>
 #include <linux/if_arp.h>
 #include <linux/trdevice.h>
-#include <linux/skbuff.h>
 #include <linux/proc_fs.h>
-#include <linux/seq_file.h>
 #include <linux/stat.h>
 #include <linux/init.h>
 #include <linux/net.h>
 #include <linux/rcupdate.h>
 #include <linux/jhash.h>
-#include <linux/slab.h>
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
 #endif
 
 #include <net/net_namespace.h>
-#include <net/ip.h>
 #include <net/icmp.h>
 #include <net/route.h>
 #include <net/protocol.h>
 #include <net/tcp.h>
-#include <net/sock.h>
 #include <net/arp.h>
 #include <net/ax25.h>
 #include <net/netrom.h>
diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index 094e150..e99b0c2 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -39,13 +39,10 @@
 #include <linux/init.h>
 #include <linux/types.h>
 #include <linux/rcupdate.h>
-#include <linux/list.h>
 #include <linux/spinlock.h>
 #include <linux/string.h>
 #include <linux/jhash.h>
 #include <linux/audit.h>
-#include <linux/slab.h>
-#include <net/ip.h>
 #include <net/icmp.h>
 #include <net/tcp.h>
 #include <net/netlabel.h>
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index c19c1f7..bd5f286 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -31,16 +31,11 @@
 #include <linux/netdevice.h>
 #include <linux/if_addr.h>
 #include <linux/if_arp.h>
-#include <linux/skbuff.h>
 #include <linux/init.h>
-#include <linux/list.h>
-#include <linux/slab.h>
 
-#include <net/ip.h>
 #include <net/protocol.h>
 #include <net/route.h>
 #include <net/tcp.h>
-#include <net/sock.h>
 #include <net/arp.h>
 #include <net/ip_fib.h>
 #include <net/rtnetlink.h>
diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
index b3acb04..aafa420 100644
--- a/net/ipv4/fib_hash.c
+++ b/net/ipv4/fib_hash.c
@@ -29,17 +29,13 @@
 #include <linux/netdevice.h>
 #include <linux/if_arp.h>
 #include <linux/proc_fs.h>
-#include <linux/skbuff.h>
 #include <linux/netlink.h>
 #include <linux/init.h>
-#include <linux/slab.h>
 
 #include <net/net_namespace.h>
-#include <net/ip.h>
 #include <net/protocol.h>
 #include <net/route.h>
 #include <net/tcp.h>
-#include <net/sock.h>
 #include <net/ip_fib.h>
 
 #include "fib_lookup.h"
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 7981a24..1b13f54 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -24,9 +24,7 @@
 #include <linux/netlink.h>
 #include <linux/inetdevice.h>
 #include <linux/init.h>
-#include <linux/list.h>
 #include <linux/rcupdate.h>
-#include <net/ip.h>
 #include <net/route.h>
 #include <net/tcp.h>
 #include <net/ip_fib.h>
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 3e0da3e..c7020cb 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -30,16 +30,12 @@
 #include <linux/netdevice.h>
 #include <linux/if_arp.h>
 #include <linux/proc_fs.h>
-#include <linux/skbuff.h>
 #include <linux/init.h>
-#include <linux/slab.h>
 
 #include <net/arp.h>
-#include <net/ip.h>
 #include <net/protocol.h>
 #include <net/route.h>
 #include <net/tcp.h>
-#include <net/sock.h>
 #include <net/ip_fib.h>
 #include <net/netlink.h>
 #include <net/nexthop.h>
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 0f28034..a7860ea 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -67,17 +67,12 @@
 #include <linux/if_arp.h>
 #include <linux/proc_fs.h>
 #include <linux/rcupdate.h>
-#include <linux/skbuff.h>
 #include <linux/netlink.h>
 #include <linux/init.h>
-#include <linux/list.h>
-#include <linux/slab.h>
 #include <net/net_namespace.h>
-#include <net/ip.h>
 #include <net/protocol.h>
 #include <net/route.h>
 #include <net/tcp.h>
-#include <net/sock.h>
 #include <net/ip_fib.h>
 #include "fib_lookup.h"
 
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index e5d1a44..255f93a 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -74,23 +74,17 @@
 #include <linux/netdevice.h>
 #include <linux/string.h>
 #include <linux/netfilter_ipv4.h>
-#include <linux/slab.h>
-#include <net/snmp.h>
-#include <net/ip.h>
 #include <net/route.h>
 #include <net/protocol.h>
 #include <net/icmp.h>
 #include <net/tcp.h>
 #include <net/udp.h>
 #include <net/raw.h>
-#include <linux/skbuff.h>
-#include <net/sock.h>
 #include <linux/errno.h>
 #include <linux/timer.h>
 #include <linux/init.h>
 #include <asm/system.h>
 #include <asm/uaccess.h>
-#include <net/checksum.h>
 #include <net/xfrm.h>
 #include <net/inet_common.h>
 
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 2ada171..eb51603 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -14,8 +14,6 @@
 #include <linux/types.h>
 #include <linux/fcntl.h>
 #include <linux/random.h>
-#include <linux/slab.h>
-#include <linux/cache.h>
 #include <linux/init.h>
 #include <linux/time.h>
 
@@ -23,9 +21,6 @@
 #include <net/tcp.h>
 #include <net/ipv6.h>
 #include <net/inet_common.h>
-#include <net/inet_connection_sock.h>
-#include <net/inet_hashtables.h>
-#include <net/inet_timewait_sock.h>
 #include <net/inet6_hashtables.h>
 #include <net/netlink.h>
 
diff --git a/net/ipv4/inet_lro.c b/net/ipv4/inet_lro.c
index 47038cb..c54cb6e 100644
--- a/net/ipv4/inet_lro.c
+++ b/net/ipv4/inet_lro.c
@@ -30,6 +30,8 @@
 #include <linux/if_vlan.h>
 #include <linux/inet_lro.h>
 
+#include <net/inet_ecn.h>
+
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jan-Bernd Themann <themann@de.ibm.com>");
 MODULE_DESCRIPTION("Large Receive Offload (ipv4 / tcp)");
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 99461f0..bda6ce5 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -21,20 +21,14 @@
 
 #include <linux/types.h>
 #include <linux/mm.h>
-#include <linux/skbuff.h>
 #include <linux/ip.h>
 #include <linux/icmp.h>
 #include <linux/netdevice.h>
-#include <linux/slab.h>
-#include <net/sock.h>
-#include <net/ip.h>
 #include <net/tcp.h>
 #include <net/udp.h>
 #include <net/icmp.h>
-#include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/netfilter_ipv4.h>
-#include <net/checksum.h>
 #include <linux/route.h>
 #include <net/route.h>
 #include <net/xfrm.h>
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index d859bcc..58c069e 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -188,7 +188,6 @@ int ip_call_ra_chain(struct sk_buff *skb)
 static int ip_local_deliver_finish(struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb->dev);
-
 	__skb_pull(skb, ip_hdrlen(skb));
 
 	/* Point into the IP datagram, just past the header. */
diff --git a/net/ipv4/netfilter/ipt_LOG.c b/net/ipv4/netfilter/ipt_LOG.c
index 72ffc8f..227be20 100644
--- a/net/ipv4/netfilter/ipt_LOG.c
+++ b/net/ipv4/netfilter/ipt_LOG.c
@@ -12,7 +12,6 @@
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/spinlock.h>
-#include <linux/skbuff.h>
 #include <linux/if_arp.h>
 #include <linux/ip.h>
 #include <net/icmp.h>
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index 43eec80..1edbcc2 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -11,16 +11,12 @@
  */
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
-#include <linux/skbuff.h>
-#include <linux/slab.h>
 #include <linux/ip.h>
 #include <linux/udp.h>
 #include <linux/icmp.h>
 #include <net/icmp.h>
-#include <net/ip.h>
 #include <net/tcp.h>
 #include <net/route.h>
-#include <net/dst.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_ipv4/ip_tables.h>
 #include <linux/netfilter_ipv4/ipt_REJECT.h>
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index c04787c..f542fbb 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -11,11 +11,8 @@
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/timer.h>
-#include <linux/skbuff.h>
 #include <linux/gfp.h>
-#include <net/checksum.h>
 #include <net/icmp.h>
-#include <net/ip.h>
 #include <net/tcp.h>  /* For tcp_prot in getorigdst */
 #include <linux/icmp.h>
 #include <linux/udp.h>
diff --git a/net/ipv4/netfilter/nf_nat_h323.c b/net/ipv4/netfilter/nf_nat_h323.c
index 790f316..704a23e 100644
--- a/net/ipv4/netfilter/nf_nat_h323.c
+++ b/net/ipv4/netfilter/nf_nat_h323.c
@@ -10,7 +10,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/tcp.h>
 #include <net/tcp.h>
 
 #include <net/netfilter/nf_nat.h>
diff --git a/net/ipv4/netfilter/nf_nat_helper.c b/net/ipv4/netfilter/nf_nat_helper.c
index 31427fb..7b9b959 100644
--- a/net/ipv4/netfilter/nf_nat_helper.c
+++ b/net/ipv4/netfilter/nf_nat_helper.c
@@ -12,10 +12,7 @@
 #include <linux/kmod.h>
 #include <linux/types.h>
 #include <linux/timer.h>
-#include <linux/skbuff.h>
-#include <linux/tcp.h>
 #include <linux/udp.h>
-#include <net/checksum.h>
 #include <net/tcp.h>
 #include <net/route.h>
 
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index b14ec7d..1f3058b 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -41,8 +41,6 @@
 #include <linux/bottom_half.h>
 #include <linux/inetdevice.h>
 #include <linux/proc_fs.h>
-#include <linux/seq_file.h>
-#include <net/sock.h>
 #include <net/raw.h>
 
 /*
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 93bfd95..af204f4 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -80,7 +80,6 @@
 #include <linux/proc_fs.h>
 #include <linux/init.h>
 #include <linux/workqueue.h>
-#include <linux/skbuff.h>
 #include <linux/inetdevice.h>
 #include <linux/igmp.h>
 #include <linux/pkt_sched.h>
@@ -90,14 +89,10 @@
 #include <linux/jhash.h>
 #include <linux/rcupdate.h>
 #include <linux/times.h>
-#include <linux/slab.h>
-#include <net/dst.h>
 #include <net/net_namespace.h>
 #include <net/protocol.h>
-#include <net/ip.h>
 #include <net/route.h>
 #include <net/inetpeer.h>
-#include <net/sock.h>
 #include <net/ip_fib.h>
 #include <net/arp.h>
 #include <net/tcp.h>
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 650cace..064d764 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -10,10 +10,7 @@
  *      2 of the License, or (at your option) any later version.
  */
 
-#include <linux/tcp.h>
-#include <linux/slab.h>
 #include <linux/random.h>
-#include <linux/cryptohash.h>
 #include <linux/kernel.h>
 #include <net/tcp.h>
 #include <net/route.h>
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 1b4ec21..391cf76 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -12,10 +12,7 @@
 #include <linux/inetdevice.h>
 #include <linux/seqlock.h>
 #include <linux/init.h>
-#include <linux/slab.h>
-#include <net/snmp.h>
 #include <net/icmp.h>
-#include <net/ip.h>
 #include <net/route.h>
 #include <net/tcp.h>
 #include <net/udp.h>
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index f15c36a..a917b0b 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -252,7 +252,6 @@
 #include <linux/poll.h>
 #include <linux/init.h>
 #include <linux/fs.h>
-#include <linux/skbuff.h>
 #include <linux/scatterlist.h>
 #include <linux/splice.h>
 #include <linux/net.h>
@@ -261,18 +260,13 @@
 #include <linux/bootmem.h>
 #include <linux/highmem.h>
 #include <linux/swap.h>
-#include <linux/cache.h>
 #include <linux/err.h>
-#include <linux/crypto.h>
 #include <linux/time.h>
-#include <linux/slab.h>
 
 #include <net/icmp.h>
 #include <net/tcp.h>
 #include <net/xfrm.h>
-#include <net/ip.h>
 #include <net/netdma.h>
-#include <net/sock.h>
 
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 850c737..0462c67 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -9,7 +9,6 @@
 #include <linux/module.h>
 #include <linux/mm.h>
 #include <linux/types.h>
-#include <linux/list.h>
 #include <linux/gfp.h>
 #include <net/tcp.h>
 
diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
index 939edb3..a35bfb6 100644
--- a/net/ipv4/tcp_diag.c
+++ b/net/ipv4/tcp_diag.c
@@ -13,8 +13,6 @@
 #include <linux/module.h>
 #include <linux/inet_diag.h>
 
-#include <linux/tcp.h>
-
 #include <net/tcp.h>
 
 static void tcp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
diff --git a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp_illinois.c
index 00ca688..546cc48 100644
--- a/net/ipv4/tcp_illinois.c
+++ b/net/ipv4/tcp_illinois.c
@@ -13,7 +13,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/skbuff.h>
 #include <linux/inet_diag.h>
 #include <asm/div64.h>
 #include <net/tcp.h>
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 6d8ab1c..43b27e7 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -62,13 +62,12 @@
  */
 
 #include <linux/mm.h>
-#include <linux/slab.h>
 #include <linux/module.h>
 #include <linux/sysctl.h>
 #include <linux/kernel.h>
-#include <net/dst.h>
 #include <net/tcp.h>
 #include <net/inet_common.h>
+#include <net/inet_ecn.h>
 #include <linux/ipsec.h>
 #include <asm/unaligned.h>
 #include <net/netdma.h>
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index d978bb2..028fc57 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -56,15 +56,12 @@
 #include <linux/fcntl.h>
 #include <linux/module.h>
 #include <linux/random.h>
-#include <linux/cache.h>
 #include <linux/jhash.h>
 #include <linux/init.h>
 #include <linux/times.h>
-#include <linux/slab.h>
 
 #include <net/net_namespace.h>
 #include <net/icmp.h>
-#include <net/inet_hashtables.h>
 #include <net/tcp.h>
 #include <net/transp_v6.h>
 #include <net/ipv6.h>
@@ -77,9 +74,7 @@
 #include <linux/ipv6.h>
 #include <linux/stddef.h>
 #include <linux/proc_fs.h>
-#include <linux/seq_file.h>
 
-#include <linux/crypto.h>
 #include <linux/scatterlist.h>
 
 int sysctl_tcp_tw_reuse __read_mostly;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index a66735f..ccbc61b 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -20,7 +20,6 @@
 
 #include <linux/mm.h>
 #include <linux/module.h>
-#include <linux/slab.h>
 #include <linux/sysctl.h>
 #include <linux/workqueue.h>
 #include <net/tcp.h>
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 61c2463..d4da881 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -35,6 +35,7 @@
  */
 
 #include <net/tcp.h>
+#include <net/inet_ecn.h>
 
 #include <linux/compiler.h>
 #include <linux/gfp.h>
diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index 6211e21..4af3525 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -21,8 +21,6 @@
 #include <linux/kernel.h>
 #include <linux/kprobes.h>
 #include <linux/socket.h>
-#include <linux/tcp.h>
-#include <linux/slab.h>
 #include <linux/proc_fs.h>
 #include <linux/module.h>
 #include <linux/ktime.h>
diff --git a/net/ipv4/tcp_vegas.c b/net/ipv4/tcp_vegas.c
index c6743ee..b4e0cc3 100644
--- a/net/ipv4/tcp_vegas.c
+++ b/net/ipv4/tcp_vegas.c
@@ -33,7 +33,6 @@
 
 #include <linux/mm.h>
 #include <linux/module.h>
-#include <linux/skbuff.h>
 #include <linux/inet_diag.h>
 
 #include <net/tcp.h>
diff --git a/net/ipv4/tcp_veno.c b/net/ipv4/tcp_veno.c
index 38bc0b5..9c922a6 100644
--- a/net/ipv4/tcp_veno.c
+++ b/net/ipv4/tcp_veno.c
@@ -11,7 +11,6 @@
 
 #include <linux/mm.h>
 #include <linux/module.h>
-#include <linux/skbuff.h>
 #include <linux/inet_diag.h>
 
 #include <net/tcp.h>
diff --git a/net/ipv4/tcp_westwood.c b/net/ipv4/tcp_westwood.c
index a534dda..55ce2bd 100644
--- a/net/ipv4/tcp_westwood.c
+++ b/net/ipv4/tcp_westwood.c
@@ -23,7 +23,6 @@
 
 #include <linux/mm.h>
 #include <linux/module.h>
-#include <linux/skbuff.h>
 #include <linux/inet_diag.h>
 #include <net/tcp.h>
 
diff --git a/net/ipv4/tcp_yeah.c b/net/ipv4/tcp_yeah.c
index a0f2403..afa7b9b 100644
--- a/net/ipv4/tcp_yeah.c
+++ b/net/ipv4/tcp_yeah.c
@@ -8,7 +8,6 @@
  */
 #include <linux/mm.h>
 #include <linux/module.h>
-#include <linux/skbuff.h>
 #include <linux/inet_diag.h>
 
 #include <net/tcp.h>
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 848b355..de9eed0 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -53,7 +53,6 @@
 #include <linux/route.h>
 #include <linux/inetdevice.h>
 #include <linux/init.h>
-#include <linux/slab.h>
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
 #endif
@@ -63,8 +62,6 @@
 #include <linux/string.h>
 
 #include <net/net_namespace.h>
-#include <net/sock.h>
-#include <net/snmp.h>
 
 #include <net/ipv6.h>
 #include <net/protocol.h>
@@ -72,7 +69,6 @@
 #include <net/ip6_route.h>
 #include <net/addrconf.h>
 #include <net/tcp.h>
-#include <net/ip.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
 #include <linux/if_tunnel.h>
@@ -86,7 +82,6 @@
 #include <asm/unaligned.h>
 
 #include <linux/proc_fs.h>
-#include <linux/seq_file.h>
 
 /* Set to 3 to get tracing... */
 #define ACONF_DEBUG 2
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 54e8e42..4f88f57 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -36,14 +36,12 @@
 #include <linux/proc_fs.h>
 #include <linux/stat.h>
 #include <linux/init.h>
-#include <linux/slab.h>
 
 #include <linux/inet.h>
 #include <linux/netdevice.h>
 #include <linux/icmpv6.h>
 #include <linux/netfilter_ipv6.h>
 
-#include <net/ip.h>
 #include <net/ipv6.h>
 #include <net/udp.h>
 #include <net/udplite.h>
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index d1770e0..8c57522 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -36,10 +36,7 @@
 #include <linux/init.h>
 #include <linux/sysctl.h>
 #include <linux/netfilter.h>
-#include <linux/slab.h>
 
-#include <net/sock.h>
-#include <net/snmp.h>
 #include <net/ipv6.h>
 #include <net/ndisc.h>
 #include <net/protocol.h>
diff --git a/net/ipv6/netfilter/ip6t_LOG.c b/net/ipv6/netfilter/ip6t_LOG.c
index 09c8889..6a15d2c 100644
--- a/net/ipv6/netfilter/ip6t_LOG.c
+++ b/net/ipv6/netfilter/ip6t_LOG.c
@@ -11,7 +11,6 @@
  */
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
-#include <linux/skbuff.h>
 #include <linux/if_arp.h>
 #include <linux/ip.h>
 #include <linux/spinlock.h>
diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index 2933396..97f5559 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -18,7 +18,6 @@
 
 #include <linux/gfp.h>
 #include <linux/module.h>
-#include <linux/skbuff.h>
 #include <linux/icmpv6.h>
 #include <linux/netdevice.h>
 #include <net/ipv6.h>
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 24b3558..05d0a01 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -19,11 +19,8 @@
 #include <linux/net.h>
 #include <linux/ipv6.h>
 #include <linux/proc_fs.h>
-#include <linux/seq_file.h>
 #include <linux/stddef.h>
 #include <net/net_namespace.h>
-#include <net/ip.h>
-#include <net/sock.h>
 #include <net/tcp.h>
 #include <net/udp.h>
 #include <net/transp_v6.h>
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 7659d6f..4ad5609 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -38,11 +38,8 @@
 #include <linux/init.h>
 #include <linux/if_arp.h>
 #include <linux/proc_fs.h>
-#include <linux/seq_file.h>
 #include <linux/nsproxy.h>
-#include <linux/slab.h>
 #include <net/net_namespace.h>
-#include <net/snmp.h>
 #include <net/ipv6.h>
 #include <net/ip6_fib.h>
 #include <net/ip6_route.h>
@@ -50,7 +47,6 @@
 #include <net/addrconf.h>
 #include <net/tcp.h>
 #include <linux/rtnetlink.h>
-#include <net/dst.h>
 #include <net/xfrm.h>
 #include <net/netevent.h>
 #include <net/netlink.h>
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 09fd34f..edf879a 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -14,9 +14,7 @@
  *
  */
 
-#include <linux/tcp.h>
 #include <linux/random.h>
-#include <linux/cryptohash.h>
 #include <linux/kernel.h>
 #include <net/ipv6.h>
 #include <net/tcp.h>
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 7e41e2c..ea31a6c 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -38,7 +38,6 @@
 #include <linux/jhash.h>
 #include <linux/ipsec.h>
 #include <linux/times.h>
-#include <linux/slab.h>
 
 #include <linux/ipv6.h>
 #include <linux/icmpv6.h>
@@ -56,7 +55,6 @@
 #include <net/inet_ecn.h>
 #include <net/protocol.h>
 #include <net/xfrm.h>
-#include <net/snmp.h>
 #include <net/dsfield.h>
 #include <net/timewait_sock.h>
 #include <net/netdma.h>
@@ -65,9 +63,7 @@
 #include <asm/uaccess.h>
 
 #include <linux/proc_fs.h>
-#include <linux/seq_file.h>
 
-#include <linux/crypto.h>
 #include <linux/scatterlist.h>
 
 static void	tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb);
diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index a475ede..eff8bc5 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -23,18 +23,15 @@
 
 #include <linux/module.h>
 #include <linux/kernel.h>
-#include <linux/skbuff.h>
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/netfilter.h>
-#include <linux/slab.h>
 #include <net/net_namespace.h>
 #include <net/protocol.h>
 #include <net/tcp.h>
 #include <asm/system.h>
 #include <linux/stat.h>
 #include <linux/proc_fs.h>
-#include <linux/seq_file.h>
 #include <linux/mutex.h>
 
 #include <net/ip_vs.h>
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index b4e51e9..1320e63 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -30,12 +30,9 @@
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/ip.h>
-#include <linux/tcp.h>
 #include <linux/sctp.h>
 #include <linux/icmp.h>
-#include <linux/slab.h>
 
-#include <net/ip.h>
 #include <net/tcp.h>
 #include <net/udp.h>
 #include <net/icmp.h>                   /* for icmp_send */
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 7545500..d87af27 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -28,7 +28,6 @@
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/kernel.h>
-#include <linux/skbuff.h>
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/netfilter.h>
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index c539983..fff800e 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -18,7 +18,6 @@
 
 #include <linux/module.h>
 #include <linux/kernel.h>
-#include <linux/skbuff.h>
 #include <linux/gfp.h>
 #include <linux/in.h>
 #include <linux/ip.h>
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index f6c5200..42d7e8b 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -18,8 +18,6 @@
 
 #include <linux/kernel.h>
 #include <linux/ip.h>
-#include <linux/tcp.h>                  /* for tcphdr */
-#include <net/ip.h>
 #include <net/tcp.h>                    /* for csum_tcpudp_magic */
 #include <net/ip6_checksum.h>
 #include <linux/netfilter.h>
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index de04ea3..e8df9b7 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -27,9 +27,6 @@
 #define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
 
 #include <linux/kernel.h>
-#include <linux/slab.h>
-#include <linux/tcp.h>                  /* for tcphdr */
-#include <net/ip.h>
 #include <net/tcp.h>                    /* for csum_tcpudp_magic */
 #include <net/udp.h>
 #include <net/icmp.h>                   /* for icmp_send */
diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index e17cb7c..8025026 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -13,11 +13,9 @@
 #include <linux/moduleparam.h>
 #include <linux/netfilter.h>
 #include <linux/ip.h>
-#include <linux/slab.h>
 #include <linux/ipv6.h>
 #include <linux/ctype.h>
 #include <linux/inet.h>
-#include <net/checksum.h>
 #include <net/tcp.h>
 
 #include <net/netfilter/nf_conntrack.h>
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 3fb2b73..7542a2f 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -10,9 +10,7 @@
 #include <linux/timer.h>
 #include <linux/module.h>
 #include <linux/in.h>
-#include <linux/tcp.h>
 #include <linux/spinlock.h>
-#include <linux/skbuff.h>
 #include <linux/ipv6.h>
 #include <net/ip6_checksum.h>
 #include <asm/unaligned.h>
diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index eb81c38..bfff091 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -9,12 +9,9 @@
  */
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
-#include <linux/skbuff.h>
 #include <linux/ip.h>
 #include <linux/gfp.h>
 #include <linux/ipv6.h>
-#include <linux/tcp.h>
-#include <net/dst.h>
 #include <net/flow.h>
 #include <net/ipv6.h>
 #include <net/route.h>
diff --git a/net/netfilter/xt_TCPOPTSTRIP.c b/net/netfilter/xt_TCPOPTSTRIP.c
index 9dc9ecf..4b12bad 100644
--- a/net/netfilter/xt_TCPOPTSTRIP.c
+++ b/net/netfilter/xt_TCPOPTSTRIP.c
@@ -10,10 +10,8 @@
  */
 
 #include <linux/module.h>
-#include <linux/skbuff.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
-#include <linux/tcp.h>
 #include <net/ipv6.h>
 #include <net/tcp.h>
 #include <linux/netfilter/x_tables.h>
diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
index 4327e10..b7b696a 100644
--- a/net/netfilter/xt_osf.c
+++ b/net/netfilter/xt_osf.c
@@ -23,13 +23,8 @@
 #include <linux/if.h>
 #include <linux/inetdevice.h>
 #include <linux/ip.h>
-#include <linux/list.h>
 #include <linux/rculist.h>
-#include <linux/skbuff.h>
-#include <linux/slab.h>
-#include <linux/tcp.h>
 
-#include <net/ip.h>
 #include <net/tcp.h>
 
 #include <linux/netfilter/nfnetlink.h>
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 00d6ae8..3f63ec5 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -11,13 +11,11 @@
  */
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
-#include <linux/skbuff.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_ipv4/ip_tables.h>
 #include <net/tcp.h>
 #include <net/udp.h>
 #include <net/icmp.h>
-#include <net/sock.h>
 #include <net/inet_sock.h>
 #include <net/netfilter/nf_tproxy_core.h>
 #include <net/netfilter/ipv4/nf_defrag_ipv4.h>
diff --git a/net/netfilter/xt_tcpmss.c b/net/netfilter/xt_tcpmss.c
index c53d4d1..19f71a4 100644
--- a/net/netfilter/xt_tcpmss.c
+++ b/net/netfilter/xt_tcpmss.c
@@ -9,7 +9,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/skbuff.h>
 #include <net/tcp.h>
 
 #include <linux/netfilter/xt_tcpmss.h>
diff --git a/net/netfilter/xt_tcpudp.c b/net/netfilter/xt_tcpudp.c
index c14d464..ca24142 100644
--- a/net/netfilter/xt_tcpudp.c
+++ b/net/netfilter/xt_tcpudp.c
@@ -1,7 +1,6 @@
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/types.h>
 #include <linux/module.h>
-#include <net/ip.h>
 #include <linux/ipv6.h>
 #include <net/ipv6.h>
 #include <net/tcp.h>
diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index 8e0a320..15814ea 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -31,7 +31,6 @@
  *
  */
 #include <linux/kernel.h>
-#include <linux/slab.h>
 #include <linux/in.h>
 #include <net/tcp.h>
 
diff --git a/net/rds/tcp_recv.c b/net/rds/tcp_recv.c
index 78205e2..82a2614 100644
--- a/net/rds/tcp_recv.c
+++ b/net/rds/tcp_recv.c
@@ -31,7 +31,6 @@
  *
  */
 #include <linux/kernel.h>
-#include <linux/slab.h>
 #include <net/tcp.h>
 
 #include "rds.h"
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index 67dc7ce..55354e6 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -20,9 +20,6 @@
 #include <net/netlink.h>
 #include <linux/rtnetlink.h>
 
-#include <linux/skbuff.h>
-
-#include <net/ip.h>
 #include <net/ipv6.h>
 #include <net/icmp.h>
 #include <linux/icmpv6.h>
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index 186eb83..0dda31a 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -15,14 +15,11 @@
 #include <linux/module.h>
 #include <linux/netfilter.h>
 #include <linux/rtnetlink.h>
-#include <linux/skbuff.h>
-#include <linux/slab.h>
 #include <linux/spinlock.h>
 #include <linux/string.h>
 #include <linux/tc_act/tc_nat.h>
 #include <net/act_api.h>
 #include <net/icmp.h>
-#include <net/ip.h>
 #include <net/netlink.h>
 #include <net/tc_act/tc_nat.h>
 #include <net/tcp.h>
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 07919e1..8659740 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -27,16 +27,10 @@
 #include <linux/in.h>
 #include <linux/inet.h>
 #include <linux/udp.h>
-#include <linux/tcp.h>
 #include <linux/unistd.h>
-#include <linux/slab.h>
 #include <linux/netdevice.h>
-#include <linux/skbuff.h>
 #include <linux/file.h>
 #include <linux/freezer.h>
-#include <net/sock.h>
-#include <net/checksum.h>
-#include <net/ip.h>
 #include <net/ipv6.h>
 #include <net/tcp.h>
 #include <net/tcp_states.h>
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index dfcab5a..03786a0 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -19,7 +19,6 @@
  */
 
 #include <linux/types.h>
-#include <linux/slab.h>
 #include <linux/module.h>
 #include <linux/capability.h>
 #include <linux/pagemap.h>
@@ -29,7 +28,6 @@
 #include <linux/net.h>
 #include <linux/mm.h>
 #include <linux/udp.h>
-#include <linux/tcp.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/sched.h>
 #include <linux/sunrpc/svcsock.h>
@@ -39,8 +37,6 @@
 #include <linux/sunrpc/bc_xprt.h>
 #endif
 
-#include <net/sock.h>
-#include <net/checksum.h>
 #include <net/udp.h>
 #include <net/tcp.h>
 
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 65fa8bf..5e3cb9a 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -34,7 +34,6 @@
 #include <linux/unistd.h>
 #include <linux/mm.h>
 #include <linux/mman.h>
-#include <linux/slab.h>
 #include <linux/pagemap.h>
 #include <linux/swap.h>
 #include <linux/spinlock.h>
@@ -48,7 +47,6 @@
 #include <linux/netfilter_ipv6.h>
 #include <linux/tty.h>
 #include <net/icmp.h>
-#include <net/ip.h>		/* for local_port_range[] */
 #include <net/tcp.h>		/* struct or_callable used in sock_rcv_skb */
 #include <net/net_namespace.h>
 #include <net/netlabel.h>
@@ -59,7 +57,6 @@
 #include <linux/interrupt.h>
 #include <linux/netdevice.h>	/* for network interface checks */
 #include <linux/netlink.h>
-#include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/dccp.h>
 #include <linux/quota.h>
-- 
1.7.1

