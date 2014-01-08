From: Norbert van Bolhuis <nvbolhuis@aimvalley.nl>
Subject: [PATCH net-next v2] packet: doc: how to PACKET_MMAP with one packet
 socket for rx and tx
Date: Wed, 08 Jan 2014 15:46:44 +0100
Message-ID: <52CD64D4.5020005@aimvalley.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mika.eatserver.nl ([195.20.9.75]:52801 "EHLO mika.eatserver.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756510AbaAHOqt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 09:46:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Describe how to use one AF_PACKET socket for rx and tx.

Cc: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Norbert van Bolhuis <nvbolhuis@aimvalley.nl>
---
  Documentation/networking/packet_mmap.txt |   18 ++++++++++++++++++
  1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/packet_mmap.txt b/Documentation/networking/packet_mmap.txt
index 723bf3d..5566c20 100644
--- a/Documentation/networking/packet_mmap.txt
+++ b/Documentation/networking/packet_mmap.txt
@@ -98,6 +98,11 @@ by the kernel.
  The destruction of the socket and all associated resources
  is done by a simple call to close(fd).

+As without PACKET_MMAP, it is possible to use one socket for
+capture and transmission. This can be done by mapping the
+allocated RX and TX buffer ring with a single mmap() call. See
+"Mapping and use of the circular buffer (ring)".
+
  Next I will describe PACKET_MMAP settings and its constraints,
  also the mapping of the circular buffer in the user process and
  the use of this buffer.
@@ -414,6 +419,19 @@ tp_block_size/tp_frame_size frames there will be a gap between
  the frames. This is because a frame cannot be spawn across two
  blocks.

+To use one socket for capture and transmission, the mapping of both the RX
+and TX buffer ring has to be done with one call to mmap:
+
+    ...
+    setsockopt(fd, SOL_PACKET, PACKET_RX_RING, &foo, sizeof(foo));
+    setsockopt(fd, SOL_PACKET, PACKET_TX_RING, &bar, sizeof(bar));
+    ...
+    rx_ring = mmap(0, size * 2, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
+    tx_ring = rx_ring + size;
+
+RX must be the first as the kernel maps the TX ring memory right after
+the RX one.
+
  At the beginning of each frame there is an status field (see
  struct tpacket_hdr). If this field is 0 means that the frame is ready
  to be used for the kernel, If not, there is a frame the user can read
