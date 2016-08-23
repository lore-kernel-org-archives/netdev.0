From: sthemmin@exchange.microsoft.com
Subject: [PATCH 11/14] hv_netvsc: make netvsc_destroy_buf void
Date: Tue, 23 Aug 2016 12:29:43 -0700
Message-ID: <1471980586-18263-12-git-send-email-sthemmin@exchange.microsoft.com>
References: <1471980586-18263-1-git-send-email-sthemmin@exchange.microsoft.com>
Reply-To: sthemmin@microsoft.com
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded01.prod.phx3.secureserver.net ([208.109.80.58]:36786
        "EHLO p3plsmtps2ded01.prod.phx3.secureserver.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754092AbcHWRy3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 13:54:29 -0400
In-Reply-To: <1471980586-18263-1-git-send-email-sthemmin@exchange.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <sthemmin@microsoft.com>

No caller checks the return value.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 830aae2..471c476 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -206,12 +206,12 @@ get_in_err:
 	return net_device;
 }
 
-static int netvsc_destroy_buf(struct hv_device *device)
+static void netvsc_destroy_buf(struct hv_device *device)
 {
 	struct nvsp_message *revoke_packet;
-	int ret = 0;
 	struct net_device *ndev = hv_get_drvdata(device);
 	struct netvsc_device *net_device = net_device_to_netvsc_device(ndev);
+	int ret;
 
 	/*
 	 * If we got a section count, it means we received a
@@ -241,7 +241,7 @@ static int netvsc_destroy_buf(struct hv_device *device)
 		if (ret != 0) {
 			netdev_err(ndev, "unable to send "
 				"revoke receive buffer to netvsp\n");
-			return ret;
+			return;
 		}
 	}
 
@@ -256,7 +256,7 @@ static int netvsc_destroy_buf(struct hv_device *device)
 		if (ret != 0) {
 			netdev_err(ndev,
 				   "unable to teardown receive buffer's gpadl\n");
-			return ret;
+			return;
 		}
 		net_device->recv_buf_gpadl_handle = 0;
 	}
@@ -300,7 +300,7 @@ static int netvsc_destroy_buf(struct hv_device *device)
 		if (ret != 0) {
 			netdev_err(ndev, "unable to send "
 				   "revoke send buffer to netvsp\n");
-			return ret;
+			return;
 		}
 	}
 	/* Teardown the gpadl on the vsp end */
@@ -314,7 +314,7 @@ static int netvsc_destroy_buf(struct hv_device *device)
 		if (ret != 0) {
 			netdev_err(ndev,
 				   "unable to teardown send buffer's gpadl\n");
-			return ret;
+			return;
 		}
 		net_device->send_buf_gpadl_handle = 0;
 	}
@@ -324,8 +324,6 @@ static int netvsc_destroy_buf(struct hv_device *device)
 		net_device->send_buf = NULL;
 	}
 	kfree(net_device->send_section_map);
-
-	return ret;
 }
 
 static int netvsc_init_buf(struct hv_device *device)
-- 
1.7.4.1
