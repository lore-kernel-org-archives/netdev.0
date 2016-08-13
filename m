From: Eric Leblond <eric@regit.org>
Subject: [PATCH net-next 1/2] tools lib bpf: suppress useless include
Date: Sat, 13 Aug 2016 14:17:22 +0200
Message-ID: <1471090643-22403-2-git-send-email-eric@regit.org>
References: <1471090643-22403-1-git-send-email-eric@regit.org>
Cc: Alexei Starovoitov <ast@fb.com>, wangnan0@huawei.com,
	Eric Leblond <eric@regit.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from home.regit.org ([37.187.126.138]:43861 "EHLO home.regit.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752117AbcHMMjP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Aug 2016 08:39:15 -0400
In-Reply-To: <1471090643-22403-1-git-send-email-eric@regit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The include of err.h is not explicitely needed in exported
functions and it was causing include conflict with some existing
code due to redefining some macros.

Signed-off-by: Eric Leblond <eric@regit.org>
---
 tools/lib/bpf/libbpf.c | 1 +
 tools/lib/bpf/libbpf.h | 1 -
 2 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
index b699aea..7872ff6 100644
--- a/tools/lib/bpf/libbpf.c
+++ b/tools/lib/bpf/libbpf.c
@@ -31,6 +31,7 @@
 #include <linux/kernel.h>
 #include <linux/bpf.h>
 #include <linux/list.h>
+#include <linux/err.h>
 #include <libelf.h>
 #include <gelf.h>
 
diff --git a/tools/lib/bpf/libbpf.h b/tools/lib/bpf/libbpf.h
index dd7a513..a6c5cde 100644
--- a/tools/lib/bpf/libbpf.h
+++ b/tools/lib/bpf/libbpf.h
@@ -23,7 +23,6 @@
 
 #include <stdio.h>
 #include <stdbool.h>
-#include <linux/err.h>
 
 enum libbpf_errno {
 	__LIBBPF_ERRNO__START = 4000,
-- 
2.8.1
