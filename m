From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH net-next 2/2] hv_netvsc: Allocate the sendbuf in a NUMA aware way
Date: Thu, 28 May 2015 17:08:07 -0700
Message-ID: <1432858087-4704-2-git-send-email-kys@microsoft.com>
References: <1432858064-4627-1-git-send-email-kys@microsoft.com>
 <1432858087-4704-1-git-send-email-kys@microsoft.com>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded04.prod.phx3.secureserver.net ([208.109.80.198]:41505
	"EHLO p3plsmtps2ded04.prod.phx3.secureserver.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754566AbbE1WrM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 18:47:12 -0400
In-Reply-To: <1432858087-4704-1-git-send-email-kys@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allocate the send buffer in a NUMA aware way.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/netvsc.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index d187965..06de98a 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -326,7 +326,9 @@ static int netvsc_init_buf(struct hv_device *device)
 
 	/* Now setup the send buffer.
 	 */
-	net_device->send_buf = vzalloc(net_device->send_buf_size);
+	net_device->send_buf = vzalloc_node(net_device->send_buf_size, node);
+	if (!net_device->send_buf)
+		net_device->send_buf = vzalloc(net_device->send_buf_size);
 	if (!net_device->send_buf) {
 		netdev_err(ndev, "unable to allocate send "
 			   "buffer of size %d\n", net_device->send_buf_size);
-- 
1.7.4.1
