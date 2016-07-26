From: ggarcia@abra.uab.cat
Subject: [PATCH v2 0/1] virtio-vsock: Add timer to handle OOM situations
Date: Tue, 26 Jul 2016 16:28:20 +0200
Message-ID: <20160726142821.31770-1-ggarcia@deic.uab.cat>
Content-Transfer-Encoding: 7BIT
Cc: stefanha@redhat.com, Gerard Garcia <ggarcia@abra.uab.cat>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from damascus.uab.es ([158.109.168.135]:49559 "EHLO damascus.uab.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754552AbcGZO2j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2016 10:28:39 -0400
Received: from damascus.uab.es ([127.0.0.1])
 by damascus.uab.es (Sun Java System Messaging Server 6.1 HotFix 0.10 (built
 Jan  6 2005)) with ESMTP id <0OAX008NJEVOR610@damascus.uab.es> for
 netdev@vger.kernel.org; Tue, 26 Jul 2016 16:28:37 +0200 (CEST)
Received: from abra.uab.es ([158.109.79.4])
 by damascus.uab.es (Sun Java System Messaging Server 6.1 HotFix 0.10 (built
 Jan  6 2005)) with ESMTP id <0OAX00BHWEVOXHR2@damascus.uab.es> for
 netdev@vger.kernel.org; Tue, 26 Jul 2016 16:28:36 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerard Garcia <ggarcia@deic.uab.cat>

This patch applies over the stefanha/vsock-next repository:
https://github.com/stefanha/linux/tree/vsock-next

Once the guest puts a packet in the virtqueue it is guaranteed
that it will be delivered. 

This patch addresses the problem of packets being discarded when 
there is not available memory in the host.

v2:
* Use of ERR_PTR/PTR_ERR/IS_ERR
* Timer cleaned on device release.
* Do not process more packets on error.

Gerard Garcia (1):
  Add timer to handle OOM situations

 drivers/vhost/vsock.c | 55 +++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 45 insertions(+), 10 deletions(-)

-- 
2.9.1
