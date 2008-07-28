From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: [PATCH] IPv6:Fix the return value of Set Hop-by-Hop options header
 with NULL data pointer
Date: Mon, 28 Jul 2008 10:46:03 +0800
Message-ID: <488D32EB.4@cn.fujitsu.com>
References: <20080722212927.937523165@vyatta.com> <20080722212951.706497135@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61642 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750728AbYG1Cuq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jul 2008 22:50:46 -0400
In-Reply-To: <20080722212951.706497135@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
