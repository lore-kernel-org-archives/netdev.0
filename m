From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] i386: optimize memset of 6 and 8 bytes
Date: Fri, 17 Aug 2007 16:50:30 -0700
Message-ID: <20070817165030.5455f761@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38455 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753218AbXHQXun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 19:50:43 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tne network code does memset for 6 and 8 byte values, that can easily
be optimized into simple assignments without string instructions.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/include/asm-i386/string.h	2007-08-17 15:14:37.000000000 -0700
+++ b/include/asm-i386/string.h	2007-08-17 16:49:10.000000000 -0700
@@ -228,6 +228,14 @@ static __always_inline void * __constant
 		case 4:
 			*(unsigned long *)s = pattern;
 			return s;
+		case 6:
+			*(unsigned long *)s = pattern;
+			*(2+(unsigned short *)s) = pattern;
+			return s;
+		case 8:
+			*(unsigned long *)s = pattern;
+			*(1+(unsigned long *)s) = pattern;
+			return s;
 	}
 #define COMMON(x) \
 __asm__  __volatile__( \
