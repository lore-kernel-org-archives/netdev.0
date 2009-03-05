From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 11/13] forcedeth: performance changes
Date: Thu, 05 Mar 2009 13:02:30 -0500
Message-ID: <49B013B6.1010202@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030006000605080201010705"
To: Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>,
	nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:8454 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755627AbZCEVBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 16:01:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030006000605080201010705
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch modifies the throughput mode poll settings to reduce the 
number of interrupts. This is only used by older hardware that need a 
timer irq in throughput mode.

Secondly, this patch increases the default rx ring from 128 to 512. This 
drastically improves bandwidth utilization for small packets sizes i.e 
512 bytes.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------030006000605080201010705
Content-Type: text/plain;
 name="patch-forcedeth-perf"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-perf"

--- old/drivers/net/forcedeth.c	2009-03-05 10:46:55.000000000 -0800
+++ new/drivers/net/forcedeth.c	2009-03-05 10:47:10.000000000 -0800
@@ -128,7 +128,7 @@
  * NVREG_POLL_DEFAULT=97 would result in an interval length of 1 ms
  */
 	NvRegPollingInterval = 0x00c,
-#define NVREG_POLL_DEFAULT_THROUGHPUT	970 /* backup tx cleanup if loop max reached */
+#define NVREG_POLL_DEFAULT_THROUGHPUT	65535 /* backup tx cleanup if loop max reached */
 #define NVREG_POLL_DEFAULT_CPU	13
 	NvRegMSIMap0 = 0x020,
 	NvRegMSIMap1 = 0x024,
@@ -463,7 +463,7 @@
 /* General driver defaults */
 #define NV_WATCHDOG_TIMEO	(5*HZ)
 
-#define RX_RING_DEFAULT		128
+#define RX_RING_DEFAULT		512
 #define TX_RING_DEFAULT		256
 #define RX_RING_MIN		128
 #define TX_RING_MIN		64

--------------030006000605080201010705--
