From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [2.6 PATCH] IPV6: Check length of optval provided by user in
 setsockopt()
Date: Mon, 07 Apr 2008 09:42:07 +0800
Message-ID: <47F97BEF.2070205@cn.fujitsu.com>
References: <47F0AA16.1070900@cn.fujitsu.com>	<20080331.181551.118587102.yoshfuji@linux-ipv6.org>	<47F0C101.9090302@cn.fujitsu.com> <20080331.195323.83430743.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49976 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752800AbYDGBnB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Apr 2008 21:43:01 -0400
In-Reply-To: <20080331.195323.83430743.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki said the following on 2008-3-31 18:53:
> POSIX, as we have some comments in that file ;-).
> If it is shorter than expected, -EINVAL, otherwise, no error.
> We need to fix other sites as well.
> 

Check length of setsockopt's optval, which provided by user, before copy it
from user space.
For POSIX compliant, return -EINVAL for setsockopt of short lengths.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/ipv6/ipv6_sockglue.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index bf2a686..a5ac121 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -557,6 +557,9 @@ done:
 	{
 		struct ipv6_mreq mreq;
 
+		if (optlen < sizeof(struct ipv6_mreq))
+			goto e_inval;
+
 		retv = -EPROTO;
 		if (inet_sk(sk)->is_icsk)
 			break;
@@ -576,7 +579,7 @@ done:
 	{
 		struct ipv6_mreq mreq;
 
-		if (optlen != sizeof(struct ipv6_mreq))
+		if (optlen < sizeof(struct ipv6_mreq))
 			goto e_inval;
 
 		retv = -EFAULT;
@@ -595,6 +598,9 @@ done:
 		struct group_req greq;
 		struct sockaddr_in6 *psin6;
 
+		if (optlen < sizeof(struct group_req))
+			goto e_inval;
+
 		retv = -EFAULT;
 		if (copy_from_user(&greq, optval, sizeof(struct group_req)))
 			break;
@@ -619,7 +625,7 @@ done:
 		struct group_source_req greqs;
 		int omode, add;
 
-		if (optlen != sizeof(struct group_source_req))
+		if (optlen < sizeof(struct group_source_req))
 			goto e_inval;
 		if (copy_from_user(&greqs, optval, sizeof(greqs))) {
 			retv = -EFAULT;
-- 
1.5.4

