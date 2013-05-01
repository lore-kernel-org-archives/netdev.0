From: Xi Wang <xi.wang@gmail.com>
Subject: [PATCH net-next] filter: fix va_list build error
Date: Wed,  1 May 2013 16:24:08 -0400
Message-ID: <1367439848-10854-1-git-send-email-xi.wang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Xi Wang <xi.wang@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f49.google.com ([209.85.216.49]:65210 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757100Ab3EAUZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 16:25:36 -0400
Received: by mail-qa0-f49.google.com with SMTP id bs12so982201qab.1
        for <netdev@vger.kernel.org>; Wed, 01 May 2013 13:25:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following build error.

In file included from include/linux/filter.h:52:0,
                 from arch/arm/net/bpf_jit_32.c:14:
include/linux/printk.h:54:2: error: unknown type name =E2=80=98va_list=E2=
=80=99
include/linux/printk.h:105:21: error: unknown type name =E2=80=98va_lis=
t=E2=80=99
include/linux/printk.h:108:30: error: unknown type name =E2=80=98va_lis=
t=E2=80=99

Signed-off-by: Xi Wang <xi.wang@gmail.com>
---
 include/linux/filter.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index d1248f4..c050dcc 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -48,6 +48,7 @@ extern int sk_chk_filter(struct sock_filter *filter, =
unsigned int flen);
 extern int sk_get_filter(struct sock *sk, struct sock_filter __user *f=
ilter, unsigned len);
=20
 #ifdef CONFIG_BPF_JIT
+#include <stdarg.h>
 #include <linux/linkage.h>
 #include <linux/printk.h>
=20
--=20
1.8.1.2
