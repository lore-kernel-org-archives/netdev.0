From: Ben Greear <greearb@candelatech.com>
Subject: Re: Patch to latest iproute to get it to compile on FC5
Date: Wed, 13 Feb 2008 22:06:36 -0800
Message-ID: <47B3DA6C.6090400@candelatech.com>
References: <47B345D0.1020707@candelatech.com> <20080213123402.43cdbd45@extreme>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010601070301050704030004"
Cc: NetDev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:45232 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751929AbYBNGGk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2008 01:06:40 -0500
In-Reply-To: <20080213123402.43cdbd45@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010601070301050704030004
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Here's another try at the patch to make the __constant_htonl methods
be included, but without changing any of the .h files.  I tested this on
an FC2 system, and it compiles fine.

Interesting to me, it seems you are not supposed to #include 
<asm/byteorder.h> directly,
but when I tried the suggested <endian.h>, it didn't actually fix the 
problem.

Signed-off-by:  Ben Greear <greearb@candelatech.com>

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com



--------------010601070301050704030004
Content-Type: text/x-patch;
 name="iproute.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="iproute.patch"

diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 3b466bf..2b2b78e 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -34,6 +34,7 @@
 #include "ip_common.h"
 #include "tunnel.h"
 
+#include <asm/byteorder.h>
 static void usage(void) __attribute__((noreturn));
 
 static void usage(void)

--------------010601070301050704030004--
