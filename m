From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: [patch] fix up generic csum_ipv6_magic function prototype
Date: Wed, 8 Nov 2006 18:02:06 -0800
Message-ID: <000301c703a3$0eedb340$ff0da8c0@amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Linux Kernel Mailing List'" <linux-kernel@vger.kernel.org>,
	"'NetDev'" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31070 "EHLO mga09.intel.com")
	by vger.kernel.org with ESMTP id S1161783AbWKICCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Nov 2006 21:02:08 -0500
To: "'Andrew Morton'" <akpm@osdl.org>,
	"'Jeff Garzik'" <jgarzik@pobox.com>, <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The generic version of csum_ipv6_magic has the len argument declared as
__u16, while most arch dependent version declare it as __u32.  After
looking at the call site of this function, I come up to a conclusion
that __u32 is a better match with the actual usage.

Hence, patch to change argument type for greater consistency.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


---

asm-m32r and asm-parisc both have it declared as __u16. I think it is a
copy-n-paste error and needs to be fixed by arch maintainer, I hope.



--- ./include/net/ip6_checksum.h.orig	2006-11-08 18:49:50.000000000 -0800
+++ ./include/net/ip6_checksum.h	2006-11-08 18:50:04.000000000 -0800
@@ -36,7 +36,7 @@
 
 static __inline__ unsigned short int csum_ipv6_magic(struct in6_addr *saddr,
 						     struct in6_addr *daddr,
-						     __u16 len,
+						     __u32 len,
 						     unsigned short proto,
 						     unsigned int csum) 
 {

