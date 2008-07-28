From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: [PATCH] IPv6:Fix the return value of Set Hop-by-Hop options header
 with NULL data pointer
Date: Mon, 28 Jul 2008 10:56:35 +0800
Message-ID: <488D3563.9080607@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56945 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754903AbYG1C5I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jul 2008 22:57:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please ingnore prev one.

When Set Hop-by-Hop options header with NULL data 
pointer and optlen is not zero use setsockopt(),
the kernel successfully return 0 instead of 
return error EINVAL or EFAULT.

This patch fix the problem.

Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>
---
 ipv6_sockglue.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/ipv6_sockglue.c b/ipv6_sockglue.c
index ea33b26..2cabac9 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -346,6 +346,8 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		 */
 		if (optlen == 0)
 			optval = NULL;
+		else if (optval == NULL)
+			goto e_inval;
 		else if (optlen < sizeof(struct ipv6_opt_hdr) ||
 			 optlen & 0x7 || optlen > 8 * 255)
 			goto e_inval;
-- 
1.5.3.8 

-- 
Regards
Yang Hongyang
 
A new email address of FJWAN is launched from Apr.1 2007.
The updated address is: yanghy@cn.fujitsu.com
--------------------------------------------------
Yang Hongyang
Development Dept.I
Nanjing Fujitsu Nanda Software Tech. Co., Ltd.(FNST)
8/F., Civil Defense Building, No.189 Guangzhou Road,
Nanjing, 210029, China
TEL: +86+25-86630566-812
FUJITSU INTERNAL: 79955-812
FAX: +86+25-83317685
EMAIL: yanghy@cn.fujitsu.com
--------------------------------------------------
This communication is for use by the intended recipient(s) only and may contain information that is privileged, confidential and exempt from disclosure under applicable law. If you are not an intended recipient of this communication, you are hereby notified that any dissemination, distribution or copying hereof is strictly prohibited.  If you have received this communication in error, please notify me by reply e-mail, permanently delete this communication from your system, and destroy any hard copies you may have printed
