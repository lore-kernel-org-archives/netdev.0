From: ggarcia@abra.uab.cat
Subject: [PATCH v4 0/1] virtio-vsock: Add timer to handle OOM situations
Date: Thu, 04 Aug 2016 16:09:10 +0200
Message-ID: <20160804140911.23453-1-ggarcia@deic.uab.cat>
Content-Transfer-Encoding: 7BIT
Cc: stefanha@redhat.com, Gerard Garcia <ggarcia@abra.uab.cat>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from damascus.uab.es ([158.109.168.135]:33900 "EHLO damascus.uab.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756647AbcHDOK2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2016 10:10:28 -0400
Received: from damascus.uab.es ([127.0.0.1])
 by damascus.uab.es (Sun Java System Messaging Server 6.1 HotFix 0.10 (built
 Jan  6 2005)) with ESMTP id <0OBE00EA01ZL9800@damascus.uab.es> for
 netdev@vger.kernel.org; Thu, 04 Aug 2016 16:09:21 +0200 (CEST)
Received: from abra.uab.es ([158.109.79.4])
 by damascus.uab.es (Sun Java System Messaging Server 6.1 HotFix 0.10 (built
 Jan  6 2005)) with ESMTP id <0OBE00DPD1ZLXV00@damascus.uab.es> for
 netdev@vger.kernel.org; Thu, 04 Aug 2016 16:09:21 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerard Garcia <ggarcia@deic.uab.cat>

This patch applies over VSOCK RFC v6.

Once the guest puts a packet in the virtqueue it is guaranteed
that it will be delivered.

This patch addresses the problem of packets being discarded when
there is not available memory in the host.

v4:
 * Fix style.

v3:
 * Avoid race condition when freeing timer.

v2:
* Use of ERR_PTR/PTR_ERR/IS_ERR
* Timer cleaned on device release.
* Do not process more packets on error.

Gerard Garcia (1):
  Add timer to handle OOM situations

 drivers/vhost/vsock.c | 49 ++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 40 insertions(+), 9 deletions(-)

-- 
2.9.1
