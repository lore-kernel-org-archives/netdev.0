From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH iproute2 net] ip: lwtunnel: remove definition of __USE_KERNEL_IPV6_DEFS
Date: Mon, 15 May 2017 13:13:34 +0200
Message-ID: <20170515111334.23805-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <daniel@iogearbox.net>, David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:60789 "EHLO
        smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933182AbdEOLNT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 07:13:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When __USE_KERNEL_IPV6_DEFS is set, netinet/in.h will not define structures
such as in6_addr. This is useful when linux/in6.h is also included.
However, older glibc versions do not support this switch.

This patch allows iproute2 to still be compiled with older glibc versions,
along with the kernel net-next patch that updates include/linux/seg6.h.

Fixes: e8493916a8ede9970732e33ea52d30b83071f401 ("iproute: add support for SR-IPv6 lwtunnel encapsulation")
Reported-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 ip/iproute_lwtunnel.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/ip/iproute_lwtunnel.c b/ip/iproute_lwtunnel.c
index 1395f03..434e60a 100644
--- a/ip/iproute_lwtunnel.c
+++ b/ip/iproute_lwtunnel.c
@@ -20,9 +20,6 @@
 #include <linux/lwtunnel.h>
 #include <linux/mpls_iptunnel.h>
 
-#ifndef __USE_KERNEL_IPV6_DEFS
-#define __USE_KERNEL_IPV6_DEFS
-#endif
 #include <linux/seg6.h>
 #include <linux/seg6_iptunnel.h>
 #include <linux/seg6_hmac.h>
-- 
2.10.2
