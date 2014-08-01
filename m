From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] iovec: make sure the caller actually wants anything in memcpy_fromiovecend
Date: Thu, 31 Jul 2014 23:00:35 -0400
Message-ID: <1406862035-27818-1-git-send-email-sasha.levin@oracle.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sasha Levin <sasha.levin@oracle.com>
To: davem@davemloft.net, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Check for cases when the caller requests 0 bytes instead of running off
and dereferencing potentially invalid iovecs.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 lib/iovec.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/lib/iovec.c b/lib/iovec.c
index 7a7c2da..df3abd1 100644
--- a/lib/iovec.c
+++ b/lib/iovec.c
@@ -85,6 +85,10 @@ EXPORT_SYMBOL(memcpy_toiovecend);
 int memcpy_fromiovecend(unsigned char *kdata, const struct iovec *iov,
 			int offset, int len)
 {
+	/* No data? Done! */
+	if (len == 0)
+		return 0;
+
 	/* Skip over the finished iovecs */
 	while (offset >= iov->iov_len) {
 		offset -= iov->iov_len;
-- 
1.7.10.4
