From: "Marc A. Pelletier" <marc@abovesecurity.com>
Subject: [PATCH 2.6.20] Corrects small word-size dependency in exposed kernel
 structure
Date: Fri, 11 May 2007 06:01:03 -0400
Message-ID: <46443EDF.1080108@abovesecurity.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [207.253.121.237] ([207.253.121.237]:43488 "EHLO
	nagios.prod.abovesecurity.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754699AbXEKO1f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 10:27:35 -0400
Received: from [10.2.4.10] (marc.ops.abovesecurity.com [10.2.4.10])
	by nagios.prod.abovesecurity.com (Postfix) with ESMTP id A9D8E6F966
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 09:58:45 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Corrects a small word-size dependency in an exposed kernel structure
so that mmaped packet sockets will work correctly from 32-bit userspace
on a 64-bit kernel.

Signed-off-by: Marc A. Pelletier <marc@abovesecurity.com>
---

As an aside, I've considered changing the setsockopt() for that feature
so that it returns critical values back to userspace (stride between
frames, actual offsets of substructures) rather than needing userspace
to guess them, but that can't be done without

(a) breaking current users of PACKET_RX_RING; or
(b) adding a new setsockopt.

Which is best?

Also, I have a couple of sanity fixes for the ring packet implementation
I'd like to discuss.  Anyone specific maintaining that bit of code?

-- Marc A. Pelletier

--- orig/include/linux/if_packet.h      2007-05-10 14:27:49 -0400
+++ new/include/linux/if_packet.h   2007-05-10 14:27:50 -0400
@@ -50,7 +50,7 @@

 struct tpacket_hdr
 {
-       unsigned long   tp_status;
+       unsigned int    tp_status;
 #define TP_STATUS_KERNEL       0
 #define TP_STATUS_USER         1
 #define TP_STATUS_COPY         2





