From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [2.6 PATCH] IPV6: Check length of optval provided by user in setsockopt()
Date: Mon, 31 Mar 2008 17:08:38 +0800
Message-ID: <47F0AA16.1070900@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54702 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754744AbYCaJJ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2008 05:09:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check length of setsockopt's optval, which provided by user, before copy it
from user space.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/ipv6/ipv6_sockglue.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index bf2a686..1ad0ac9 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -557,6 +557,9 @@ done:
 	{
 		struct ipv6_mreq mreq;
 
+		if (optlen != sizeof(struct ipv6_mreq))
+			goto e_inval;
+
 		retv = -EPROTO;
 		if (inet_sk(sk)->is_icsk)
 			break;
@@ -595,6 +598,9 @@ done:
 		struct group_req greq;
 		struct sockaddr_in6 *psin6;
 
+		if (optlen != sizeof(struct group_req))
+			goto e_inval;
+
 		retv = -EFAULT;
 		if (copy_from_user(&greq, optval, sizeof(struct group_req)))
 			break;
-- 
1.5.3.4


