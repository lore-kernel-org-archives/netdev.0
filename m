From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/4 03/13] wimax: allow user space to send messages once the device is registered
Date: Wed,  4 Nov 2009 13:39:58 -0800
Message-ID: <de9315fa3a35ebe587cc1a1c88655d095846785e.1257370737.git.inaky@linux.intel.com>
References: <cover.1257370737.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:17987 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932763AbZKDVmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:12 -0500
In-Reply-To: <cover.1257370737.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370737.git.inaky@linux.intel.com>
References: <cover.1257370737.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It makes sense that the messaging pipe to the device can be used
before the device is fully ready, as long as it is registered with the
stack. Some debugging tools need it.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 net/wimax/op-msg.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/wimax/op-msg.c b/net/wimax/op-msg.c
index d631a17..d3bfb6e 100644
--- a/net/wimax/op-msg.c
+++ b/net/wimax/op-msg.c
@@ -388,6 +388,8 @@ int wimax_gnl_doit_msg_from_user(struct sk_buff *skb, struct genl_info *info)
 	}
 	mutex_lock(&wimax_dev->mutex);
 	result = wimax_dev_is_ready(wimax_dev);
+	if (result == -ENOMEDIUM)
+		result = 0;
 	if (result < 0)
 		goto error_not_ready;
 	result = -ENOSYS;
-- 
1.6.2.5

