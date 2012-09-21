From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] ipv6: fix return value check in fib6_add()
Date: Fri, 21 Sep 2012 12:29:56 +0800
Message-ID: <CAPgLHd9vdKJfj1yUqU+zDaH6PiuqY8ZG_V5B1py--NiDwa+WkA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:54986 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751414Ab2IUE35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 00:29:57 -0400
Received: by qcro28 with SMTP id o28so2309091qcr.19
        for <netdev@vger.kernel.org>; Thu, 20 Sep 2012 21:29:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

In case of error, the function fib6_add_1() returns ERR_PTR()
or NULL pointer. The ERR_PTR() case check is missing in fib6_add().

dpatch engine is used to generated this patch.
(https://github.com/weiyj/dpatch)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/ipv6/ip6_fib.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 13690d6..286acfc 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -819,6 +819,10 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info)
 					offsetof(struct rt6_info, rt6i_src),
 					allow_create, replace_required);
 
+			if (IS_ERR(sn)) {
+				err = PTR_ERR(sn);
+				sn = NULL;
+			}
 			if (!sn) {
 				/* If it is failed, discard just allocated
 				   root, and then (in st_failure) stale node
