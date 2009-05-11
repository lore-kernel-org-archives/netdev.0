From: Mark McLoughlin <markmc@redhat.com>
Subject: [PATCH 1/3] virtio: teach virtio_has_feature() about transport features
Date: Mon, 11 May 2009 18:11:44 +0100
Message-ID: <1242061906-16226-1-git-send-email-markmc@redhat.com>
References: <1242061838.25337.8.camel@blaa>
Cc: netdev@vger.kernel.org, Dor Laor <dor@redhat.com>,
	Avi Kivity <avi@redhat.com>,
	virtualization@lists.linux-foundation.org,
	Mark McLoughlin <markmc@redhat.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail28.svc.cra.dublin.eircom.net ([159.134.118.224]:33745 "HELO
	mail28.svc.cra.dublin.eircom.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751885AbZEKRMA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2009 13:12:00 -0400
In-Reply-To: <1242061838.25337.8.camel@blaa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers don't add transport features to their table, so we
shouldn't check these with virtio_check_driver_offered_feature().

We could perhaps add an ->offered_feature() virtio_config_op,
but that perhaps that would be overkill for a consitency check
like this.

Signed-off-by: Mark McLoughlin <markmc@redhat.com>
---
 include/linux/virtio_config.h |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/include/linux/virtio_config.h b/include/linux/virtio_config.h
index bf8ec28..e4ba694 100644
--- a/include/linux/virtio_config.h
+++ b/include/linux/virtio_config.h
@@ -99,7 +99,9 @@ static inline bool virtio_has_feature(const struct virtio_device *vdev,
 	if (__builtin_constant_p(fbit))
 		BUILD_BUG_ON(fbit >= 32);
 
-	virtio_check_driver_offered_feature(vdev, fbit);
+	if (fbit < VIRTIO_TRANSPORT_F_START)
+		virtio_check_driver_offered_feature(vdev, fbit);
+
 	return test_bit(fbit, vdev->features);
 }
 
-- 
1.6.0.6

