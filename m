From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH] net/9p: use memcpy() instead of snprintf() in
 p9_mount_tag_show()
Date: Tue, 27 Jan 2015 16:00:19 +0300
Message-ID: <1422363619-21931-1-git-send-email-a.ryabinin@samsung.com>
References: <1422290896-25042-1-git-send-email-a.ryabinin@samsung.com>
Cc: David Laight <David.Laight@ACULAB.COM>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Ron Minnich <rminnich@sandia.gov>,
	Latchesar Ionkov <lucho@ionkov.net>,
	"David S. Miller" <davem@davemloft.net>,
	v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	Andrey Ryabinin <a.ryabinin@samsung.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.w1.samsung.com ([210.118.77.12]:41571 "EHLO
	mailout2.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138AbbA0NAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 08:00:36 -0500
In-reply-to: <1422290896-25042-1-git-send-email-a.ryabinin@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

p9_mount_tag_show() uses '%s' format string to print
non-NULL terminated chan->tag string. This leads
to out of bounds memory read, because format '%s'
implies that string is NULL-terminated.

The length of string is know here, so its simpler and safer
to use memcpy instead of snprintf().

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 net/9p/trans_virtio.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
index daa749c..9d64145 100644
--- a/net/9p/trans_virtio.c
+++ b/net/9p/trans_virtio.c
@@ -504,7 +504,10 @@ static ssize_t p9_mount_tag_show(struct device *dev,
 	vdev = dev_to_virtio(dev);
 	chan = vdev->priv;
 
-	return snprintf(buf, chan->tag_len + 1, "%s", chan->tag);
+	memcpy(buf, chan->tag, chan->tag_len);
+	buf[chan->tag_len] = 0;
+
+	return chan->tag_len + 1;
 }
 
 static DEVICE_ATTR(mount_tag, 0444, p9_mount_tag_show, NULL);
-- 
2.2.2
