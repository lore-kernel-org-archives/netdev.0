From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next-2.6 5/8] sctp: use memdup_user to copy data from
 userspace
Date: Tue, 19 Apr 2011 13:13:18 +0800
Message-ID: <4DAD19EE.1070707@cn.fujitsu.com>
References: <4DAD18AB.3040401@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57380 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752320Ab1DSFNU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 01:13:20 -0400
In-Reply-To: <4DAD18AB.3040401@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>

Use common function to simply code.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/sctp/socket.c |   22 ++++++----------------
 1 files changed, 6 insertions(+), 16 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index deb82e3..5c9980a 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3215,14 +3215,9 @@ static int sctp_setsockopt_hmac_ident(struct sock *sk,
 	if (optlen < sizeof(struct sctp_hmacalgo))
 		return -EINVAL;
 
-	hmacs = kmalloc(optlen, GFP_KERNEL);
-	if (!hmacs)
-		return -ENOMEM;
-
-	if (copy_from_user(hmacs, optval, optlen)) {
-		err = -EFAULT;
-		goto out;
-	}
+	hmacs= memdup_user(optval, optlen);
+	if (IS_ERR(hmacs))
+		return PTR_ERR(hmacs);
 
 	idents = hmacs->shmac_num_idents;
 	if (idents == 0 || idents > SCTP_AUTH_NUM_HMACS ||
@@ -3257,14 +3252,9 @@ static int sctp_setsockopt_auth_key(struct sock *sk,
 	if (optlen <= sizeof(struct sctp_authkey))
 		return -EINVAL;
 
-	authkey = kmalloc(optlen, GFP_KERNEL);
-	if (!authkey)
-		return -ENOMEM;
-
-	if (copy_from_user(authkey, optval, optlen)) {
-		ret = -EFAULT;
-		goto out;
-	}
+	authkey= memdup_user(optval, optlen);
+	if (IS_ERR(authkey))
+		return PTR_ERR(authkey);
 
 	if (authkey->sca_keylength > optlen - sizeof(struct sctp_authkey)) {
 		ret = -EINVAL;
-- 
1.6.5.2


