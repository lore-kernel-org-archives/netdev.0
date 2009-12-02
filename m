From: Patrick Mullaney <pmullaney@novell.com>
Subject: [PATCH 1/2] venet-macvlan: correctly remove newline from lower device
	name
Date: Wed, 02 Dec 2009 16:10:26 -0500
Message-ID: <20091202211026.5116.67536.stgit@mimic.site>
References: <20091202204722.5116.33183.stgit@mimic.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: alacrityvm-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20091202204722.5116.33183.stgit@mimic.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Patrick Mullaney <pmullaney@novell.com>
---

 kernel/vbus/devices/venet/macvlan.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/kernel/vbus/devices/venet/macvlan.c b/kernel/vbus/devices/venet/macvlan.c
index 8724e26..432ff5d 100644
--- a/kernel/vbus/devices/venet/macvlan.c
+++ b/kernel/vbus/devices/venet/macvlan.c
@@ -350,7 +350,11 @@ ll_ifname_store(struct vbus_device *dev, struct vbus_device_attribute *attr,
 	if (priv->dev.vbus.opened)
 		return -EINVAL;
 
-	strncpy(priv->ll_ifname, buf, count-1);
+	memcpy(priv->ll_ifname, buf, count);
+
+	/* remove trailing newline if present */
+	if (priv->ll_ifname[count-1] == '\n')
+		priv->ll_ifname[count-1] = '\0';
 
 	if (priv->mdev.lowerdev) {
 		dev_put(priv->mdev.lowerdev);

