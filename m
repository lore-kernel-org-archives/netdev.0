From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH] net/9p: fix format string in p9_mount_tag_show()
Date: Mon, 26 Jan 2015 19:48:16 +0300
Message-ID: <1422290896-25042-1-git-send-email-a.ryabinin@samsung.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Ron Minnich <rminnich@sandia.gov>,
	Latchesar Ionkov <lucho@ionkov.net>,
	"David S. Miller" <davem@davemloft.net>,
	v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	Andrey Ryabinin <a.ryabinin@samsung.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.w1.samsung.com ([210.118.77.12]:11381 "EHLO
	mailout2.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756208AbbAZQs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 11:48:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using "%s" for non-NULL terminated string is quite
dangerous, since this causes reading out of bounds.
chan->tag is non-NULL terminated, so precision
must be specified for printing it.

Fixes: 86c8437383ac ("net/9p: Add sysfs mount_tag file for virtio 9P device")
Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 net/9p/trans_virtio.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
index daa749c..f0d5f90 100644
--- a/net/9p/trans_virtio.c
+++ b/net/9p/trans_virtio.c
@@ -504,7 +504,8 @@ static ssize_t p9_mount_tag_show(struct device *dev,
 	vdev = dev_to_virtio(dev);
 	chan = vdev->priv;
 
-	return snprintf(buf, chan->tag_len + 1, "%s", chan->tag);
+	return snprintf(buf, chan->tag_len + 1, "%.*s",
+			chan->tag_len, chan->tag);
 }
 
 static DEVICE_ATTR(mount_tag, 0444, p9_mount_tag_show, NULL);
-- 
2.2.2
