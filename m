From: Joe Perches <joe@perches.com>
Subject: [ofa-general] [PATCH net-2.6.25 7/8] drivers/infiniband: Use
	ipv4_is_<type>
Date: Thu, 13 Dec 2007 15:39:00 -0800
Message-ID: <1197589141-7020-7-git-send-email-joe@perches.com>
References: <1197589141-7020-1-git-send-email-joe@perches.com>
	<1197589141-7020-2-git-send-email-joe@perches.com>
	<1197589141-7020-3-git-send-email-joe@perches.com>
	<1197589141-7020-4-git-send-email-joe@perches.com>
	<1197589141-7020-5-git-send-email-joe@perches.com>
	<1197589141-7020-6-git-send-email-joe@perches.com>
Cc: general@lists.openfabrics.org
To: netdev@vger.kernel.org
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1197589141-7020-6-git-send-email-joe@perches.com>
Message-Id: <aaf1cd18672fdabaa410bff09200c6a74534bdb0.1197432867.git.joe@perches.com>
In-Reply-To: <e2ebcbf24539c0a3ef2ac77147dbfa55d8ac9e33.1197432867.git.joe@perches.com>
References: <e2ebcbf24539c0a3ef2ac77147dbfa55d8ac9e33.1197432867.git.joe@perches.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/infiniband/core/addr.c |    4 ++--
 drivers/infiniband/core/cma.c  |    5 +++--
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
index 5381c80..0802b79 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -265,11 +265,11 @@ static int addr_resolve_local(struct sockaddr_in *src_in,
 	if (!dev)
 		return -EADDRNOTAVAIL;
 
-	if (ZERONET(src_ip)) {
+	if (ipv4_is_zeronet(src_ip)) {
 		src_in->sin_family = dst_in->sin_family;
 		src_in->sin_addr.s_addr = dst_ip;
 		ret = rdma_copy_addr(addr, dev, dev->dev_addr);
-	} else if (LOOPBACK(src_ip)) {
+	} else if (ipv4_is_loopback(src_ip)) {
 		ret = rdma_translate_ip((struct sockaddr *)dst_in, addr);
 		if (!ret)
 			memcpy(addr->dst_dev_addr, dev->dev_addr, MAX_ADDR_LEN);
diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 0751697..b37045c 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -624,7 +624,8 @@ static inline int cma_zero_addr(struct sockaddr *addr)
 	struct in6_addr *ip6;
 
 	if (addr->sa_family == AF_INET)
-		return ZERONET(((struct sockaddr_in *) addr)->sin_addr.s_addr);
+		return ipv4_is_zeronet(
+			((struct sockaddr_in *)addr)->sin_addr.s_addr);
 	else {
 		ip6 = &((struct sockaddr_in6 *) addr)->sin6_addr;
 		return (ip6->s6_addr32[0] | ip6->s6_addr32[1] |
@@ -634,7 +635,7 @@ static inline int cma_zero_addr(struct sockaddr *addr)
 
 static inline int cma_loopback_addr(struct sockaddr *addr)
 {
-	return LOOPBACK(((struct sockaddr_in *) addr)->sin_addr.s_addr);
+	return ipv4_is_loopback(((struct sockaddr_in *) addr)->sin_addr.s_addr);
 }
 
 static inline int cma_any_addr(struct sockaddr *addr)
-- 
1.5.3.7.949.g2221a6
