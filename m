From: Tom Herbert <tom@herbertland.com>
Subject: [RFC net-next] net: Build IPv6 into kernel by default
Date: Thu, 9 Jul 2015 13:42:29 -0700
Message-ID: <1436474549-491618-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:40580 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754031AbbGIUmg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 16:42:36 -0400
Received: from pps.filterd (m0044008 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t69KfU6N002610
	for <netdev@vger.kernel.org>; Thu, 9 Jul 2015 13:42:35 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1vhym40364-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 13:42:35 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 072879ba267b11e5a9be0002c99331b0-9cffb2b0 for <netdev@vger.kernel.org>;	Thu,
 09 Jul 2015 13:42:34 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the default to build IPv6 into the kernel. IPv6
now has significant traction and any remaining vestiges of IPv6
not being provided parity with IPv4 should be swept away. IPv6 is now
core to the Internet and kernel.

Points on IPv6 adoption:

- Per Google statistics, IPv6 usage has reached 7% on the Internet
  and continues to exhibit an exponential growth rate
  https://www.google.com/intl/en/ipv6/statistics.html
- Just a few days ago ARIN officially depleted its IPv4 pool
- IPv6 only data centers are being successfully built
  (e.g. at Facebook)

This patch changes the IPv6 Kconfig for IPV6. Default for CONFIG_IPV6
is set to "y" and the text has been updated to reflect the maturity of
IPv6.

Impact:

Under some circumstances building modules in to kernel might have a
performance advantage. In my testing, I did notice a very slight
improvement.

This will obviously increase the size of the kernel image. In my
configuration I see:

IPv6 as module:

   text    data     bss     dec     hex filename
9703666 1899288  933888 12536842         bf4c0a vmlinux

IPv6 built into kernel

  text     data     bss     dec     hex filename
9436490 1879600  913408 12229498         ba9b7a vmlinux

Which increases text size by ~270K (2.8% increase in size for me). If
image size is an issue, presumably for a device which does not do IP
networking (IMO we should be discouraging IPv4-only devices), IPV6 can
be disabled or still built as a module.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/Kconfig | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 438a73a..a0016c5 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -5,16 +5,15 @@
 #   IPv6 as module will cause a CRASH if you try to unload it
 menuconfig IPV6
 	tristate "The IPv6 protocol"
-	default m
+	default y
 	---help---
-	  This is complemental support for the IP version 6.
-	  You will still be able to do traditional IPv4 networking as well.
+	  Support for IP version 6 (IPv6).
 
 	  For general information about IPv6, see
 	  <https://en.wikipedia.org/wiki/IPv6>.
-	  For Linux IPv6 development information, see <http://www.linux-ipv6.org>.
-	  For specific information about IPv6 under Linux, read the HOWTO at
-	  <http://www.bieringer.de/linux/IPv6/>.
+	  For specific information about IPv6 under Linux, see
+	  Documentation/networking/ipv6.txt and read the HOWTO at
+	  <http://http://www.tldp.org/HOWTO/Linux+IPv6-HOWTO/>
 
 	  To compile this protocol support as a module, choose M here: the 
 	  module will be called ipv6.
-- 
1.8.1
