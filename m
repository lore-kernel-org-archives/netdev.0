From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH net-next 2/3] net: Fix memcpy_toiovecend() to use the right
 offset
Date: Fri, 05 Jun 2009 12:35:44 -0700
Message-ID: <1244230544.1526.77.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:41362 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752478AbZFETfo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jun 2009 15:35:44 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n55JTvtm020564
	for <netdev@vger.kernel.org>; Fri, 5 Jun 2009 15:29:57 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n55JZkYd233230
	for <netdev@vger.kernel.org>; Fri, 5 Jun 2009 15:35:46 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n55JZjJa028914
	for <netdev@vger.kernel.org>; Fri, 5 Jun 2009 15:35:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Increment the iovec base by the offset passed in for the initial
copy_to_user() in memcpy_to_iovecend().

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/net/core/iovec.c b/net/core/iovec.c
index 40a76ce..16ad45d 100644
--- a/net/core/iovec.c
+++ b/net/core/iovec.c
@@ -112,9 +112,9 @@ int memcpy_toiovecend(const struct iovec *iov, unsigned char *kdata,
 			continue;
 		}
 		copy = min_t(unsigned int, iov->iov_len - offset, len);
-		offset = 0;
-		if (copy_to_user(iov->iov_base, kdata, copy))
+		if (copy_to_user(iov->iov_base + offset, kdata, copy))
 			return -EFAULT;
+		offset = 0;
 		kdata += copy;
 		len -= copy;
 	}




