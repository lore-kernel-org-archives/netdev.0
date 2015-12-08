From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 1/3] rco: Clean up casting errors
Date: Tue, 8 Dec 2015 10:27:16 -0800
Message-ID: <1449599238-4094072-2-git-send-email-tom@herbertland.com>
References: <1449599238-4094072-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<jesse@nicira.com>, <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:52569 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751718AbbLHS1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 13:27:36 -0500
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id tB8IOEmb031545
	for <netdev@vger.kernel.org>; Tue, 8 Dec 2015 10:27:36 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1ynucracxg-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 10:27:35 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 59ba04ca9dd911e5a04b0002c9521c9e-76ffc210 for <netdev@vger.kernel.org>;	Tue,
 08 Dec 2015 10:27:34 -0800
In-Reply-To: <1449599238-4094072-1-git-send-email-tom@herbertland.com>
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
