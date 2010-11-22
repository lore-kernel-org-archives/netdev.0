From: Tracey Dent <tdent48227@gmail.com>
Subject: [PATCH 14/17] Net: rds: Makefile: Remove deprecated items
Date: Sun, 21 Nov 2010 20:03:25 -0500
Message-ID: <1290387808-2239-15-git-send-email-tdent48227@gmail.com>
References: <1290387808-2239-1-git-send-email-tdent48227@gmail.com>
Cc: marcel@holtmann.org, padovan@profusion.mobi,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	sjur.brandeland@stericsson.com, socketcan@hartkopp.net,
	urs.thuermann@volkswagen.de, socketcan-core@lists.berlios.de,
	sage@newdream.net, ceph-devel@vger.kernel.org,
	wang840925@gmail.com, jlayton@redhat.com, kaber@trash.net,
	pekkas@netcore.fi, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	samuel@sortiz.org, Tracey Dent <tdent48227@gmail.com>
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1290387808-2239-1-git-send-email-tdent48227@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changed Makefile to use <modules>-y instead of <modules>-objs
because -objs is deprecated and not mentioned in
Documentation/kbuild/makefiles.txt.

Also, use the ccflags-$ flag instead of EXTRA_CFLAGS because EXTRA_CFLAGS is
deprecated and should now be switched.

Last but not least, took out if-conditionals.

Signed-off-by: Tracey Dent <tdent48227@gmail.com>
---
 net/rds/Makefile |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/rds/Makefile b/net/rds/Makefile
index b46eca1..56d3f60 100644
--- a/net/rds/Makefile
+++ b/net/rds/Makefile
@@ -4,7 +4,7 @@ rds-y :=	af_rds.o bind.o cong.o connection.o info.o message.o   \
 			loop.o page.o rdma.o
 
 obj-$(CONFIG_RDS_RDMA) += rds_rdma.o
-rds_rdma-objs :=	rdma_transport.o \
+rds_rdma-y :=	rdma_transport.o \
 			ib.o ib_cm.o ib_recv.o ib_ring.o ib_send.o ib_stats.o \
 			ib_sysctl.o ib_rdma.o \
 			iw.o iw_cm.o iw_recv.o iw_ring.o iw_send.o iw_stats.o \
@@ -12,10 +12,8 @@ rds_rdma-objs :=	rdma_transport.o \
 
 
 obj-$(CONFIG_RDS_TCP) += rds_tcp.o
-rds_tcp-objs :=		tcp.o tcp_connect.o tcp_listen.o tcp_recv.o \
+rds_tcp-y :=		tcp.o tcp_connect.o tcp_listen.o tcp_recv.o \
 			tcp_send.o tcp_stats.o
 
-ifeq ($(CONFIG_RDS_DEBUG), y)
-EXTRA_CFLAGS += -DDEBUG
-endif
+ccflags-$(CONFIG_RDS_DEBUG)	:=	-DDEBUG
 
-- 
1.7.3.2.245.g03276

