From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH iproute2 net] iproute: fix compilation issue with older glibc
Date: Fri, 16 Jun 2017 15:54:28 +0200
Message-ID: <20170616135428.18262-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:40278 "EHLO
        smtp4.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752464AbdFPNxd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 09:53:33 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp4.sgsi.ucl.ac.be (Postfix) with ESMTPS id 680F267D9F5
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 15:53:18 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a header that includes linux/in6.h is included before
iproute's utils.h, then iproute2 fails to compile on older
glibc versions.

Fixes: e8493916a8ede9970732e33ea52d30b83071f401 ("iproute: add support for SR-IPv6 lwtunnel encapsulation")
Reported-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 ip/iproute_lwtunnel.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/ip/iproute_lwtunnel.c b/ip/iproute_lwtunnel.c
index 1395f03..5c0c7d1 100644
--- a/ip/iproute_lwtunnel.c
+++ b/ip/iproute_lwtunnel.c
@@ -19,13 +19,6 @@
 #include <linux/ila.h>
 #include <linux/lwtunnel.h>
 #include <linux/mpls_iptunnel.h>
-
-#ifndef __USE_KERNEL_IPV6_DEFS
-#define __USE_KERNEL_IPV6_DEFS
-#endif
-#include <linux/seg6.h>
-#include <linux/seg6_iptunnel.h>
-#include <linux/seg6_hmac.h>
 #include <errno.h>
 
 #include "rt_names.h"
@@ -33,6 +26,10 @@
 #include "iproute_lwtunnel.h"
 #include "bpf_util.h"
 
+#include <linux/seg6.h>
+#include <linux/seg6_iptunnel.h>
+#include <linux/seg6_hmac.h>
+
 static const char *format_encap_type(int type)
 {
 	switch (type) {
-- 
2.10.2
