From: "Dmitry V. Levin" <ldv@altlinux.org>
Subject: [PATCH v2] uapi: fix linux/seg6.h and linux/seg6_iptunnel.h userspace compilation errors
Date: Thu, 23 Feb 2017 14:30:34 +0300
Message-ID: <20170223113034.GA22568@altlinux.org>
References: <20170223011355.GB16142@altlinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vmicros1.altlinux.org ([194.107.17.57]:37966 "EHLO
        vmicros1.altlinux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751119AbdBWLap (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 06:30:45 -0500
Content-Disposition: inline
In-Reply-To: <20170223011355.GB16142@altlinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Include <linux/in6.h> in uapi/linux/seg6.h to fix the following
linux/seg6.h userspace compilation error:

/usr/include/linux/seg6.h:31:18: error: array type has incomplete element type 'struct in6_addr'
  struct in6_addr segments[0];

Include <linux/seg6.h> in uapi/linux/seg6_iptunnel.h to fix
the following linux/seg6_iptunnel.h userspace compilation error:

/usr/include/linux/seg6_iptunnel.h:26:21: error: array type has incomplete element type 'struct ipv6_sr_hdr'
  struct ipv6_sr_hdr srh[0];

Fixes: a50a05f497a2 ("ipv6: sr: add missing Kbuild export for header files")
Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
---
v2: fixed "Fixes:" line

 include/uapi/linux/seg6.h          | 1 +
 include/uapi/linux/seg6_iptunnel.h | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/include/uapi/linux/seg6.h b/include/uapi/linux/seg6.h
index 61df8d3..7278511 100644
--- a/include/uapi/linux/seg6.h
+++ b/include/uapi/linux/seg6.h
@@ -15,6 +15,7 @@
 #define _UAPI_LINUX_SEG6_H
 
 #include <linux/types.h>
+#include <linux/in6.h>		/* For struct in6_addr. */
 
 /*
  * SRH
diff --git a/include/uapi/linux/seg6_iptunnel.h b/include/uapi/linux/seg6_iptunnel.h
index 7a7183d..b6e5a0a 100644
--- a/include/uapi/linux/seg6_iptunnel.h
+++ b/include/uapi/linux/seg6_iptunnel.h
@@ -14,6 +14,8 @@
 #ifndef _UAPI_LINUX_SEG6_IPTUNNEL_H
 #define _UAPI_LINUX_SEG6_IPTUNNEL_H
 
+#include <linux/seg6.h>		/* For struct ipv6_sr_hdr. */
+
 enum {
 	SEG6_IPTUNNEL_UNSPEC,
 	SEG6_IPTUNNEL_SRH,
-- 
ldv
