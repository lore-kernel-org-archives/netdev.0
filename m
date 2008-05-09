From: Brice Goglin <brice@myri.com>
Subject: [PATCH 07/16] myri10ge: add barrier in myri10ge_send_cmd
Date: Fri, 09 May 2008 02:18:45 +0200
Message-ID: <48239865.3070706@myri.com>
References: <482397A3.1050604@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1813 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756411AbYEIAqK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2008 20:46:10 -0400
In-Reply-To: <482397A3.1050604@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a barrier() in the usleep() loop in  myri10ge_send_cmd().
Without the barrier, some mips machine never notices that the
firmware has DMA'ed the response.

Signed-off-by: Brice Goglin <brice@myri.com>
Signed-off-by: Andrew Gallatin <gallatin@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: linux-2.6/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-2.6.orig/drivers/net/myri10ge/myri10ge.c    2008-05-09
00:04:48.000000000 +0200
+++ linux-2.6/drivers/net/myri10ge/myri10ge.c    2008-05-09
00:05:30.000000000 +0200
@@ -361,8 +361,10 @@
         for (sleep_total = 0;
              sleep_total < 1000
              && response->result == htonl(MYRI10GE_NO_RESPONSE_RESULT);
-             sleep_total += 10)
+             sleep_total += 10) {
             udelay(10);
+            mb();
+        }
     } else {
         /* use msleep for most command */
         for (sleep_total = 0;

