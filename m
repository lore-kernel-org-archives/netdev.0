From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next v2 1/3] rco: Clean up casting errors
Date: Thu, 10 Dec 2015 12:34:31 -0800
Message-ID: <1449779673-3701191-2-git-send-email-tom@herbertland.com>
References: <1449779673-3701191-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:43750 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753799AbbLJUem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 15:34:42 -0500
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id tBAKTpcf002501
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2015 12:34:42 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1yqfyq05m8-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2015 12:34:42 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 7063b8c49f7d11e5bbc50002c99293a0-223fc210 for <netdev@vger.kernel.org>;	Thu,
 10 Dec 2015 12:34:41 -0800
In-Reply-To: <1449779673-3701191-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixe a couple of cast errors found by sparse.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/checksum.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/net/checksum.h b/include/net/checksum.h
index 9fcaedf..10a16b5 100644
--- a/include/net/checksum.h
+++ b/include/net/checksum.h
@@ -165,7 +165,8 @@ static inline __wsum remcsum_adjust(void *ptr, __wsum csum,
 	csum = csum_sub(csum, csum_partial(ptr, start, 0));
 
 	/* Set derived checksum in packet */
-	delta = csum_sub(csum_fold(csum), *psum);
+	delta = csum_sub((__force __wsum)csum_fold(csum),
+			 (__force __wsum)*psum);
 	*psum = csum_fold(csum);
 
 	return delta;
-- 
2.4.6
