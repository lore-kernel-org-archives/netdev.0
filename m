From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH v2] include/linux: printk is needed in filter.h when CONFIG_BPF_JIT
 is defined
Date: Fri, 29 Mar 2013 09:24:53 +0800
Message-ID: <5154ED65.5090607@asianux.com>
References: <5153DC24.4010104@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: edumazet@google.com, dborkman@redhat.com, wad@chromium.org,
	eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:33883 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754426Ab3C2CXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 22:23:24 -0400
In-Reply-To: <5153DC24.4010104@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


  for make V=1 EXTRA_CFLAGS=-W ARCH=arm allmodconfig
    printk is need when CONFIG_BPF_JIT is defined
    or it will report pr_err and print_hex_dump are implicit declaration

Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 include/linux/filter.h |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index d7d2508..d1248f4 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -48,6 +48,9 @@ extern int sk_chk_filter(struct sock_filter *filter, unsigned int flen);
 extern int sk_get_filter(struct sock *sk, struct sock_filter __user *filter, unsigned len);
 
 #ifdef CONFIG_BPF_JIT
+#include <linux/linkage.h>
+#include <linux/printk.h>
+
 extern void bpf_jit_compile(struct sk_filter *fp);
 extern void bpf_jit_free(struct sk_filter *fp);
 
-- 
1.7.7.6
