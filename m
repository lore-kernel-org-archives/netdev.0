From: Dave Jones <davej@redhat.com>
Subject: hyperv: fix apparent cut-n-paste error in send path teardown
Date: Mon, 16 Jun 2014 16:59:02 -0400
Message-ID: <20140616205902.GA7331@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kys@microsoft.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57822 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932379AbaFPU7M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2014 16:59:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

c25aaf814a63: "hyperv: Enable sendbuf mechanism on the send path" added
some teardown code that looks like it was copied from the recieve path
above, but missed a variable name replacement.

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index c041f63a6d30..4ed38eaecea8 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -189,7 +189,7 @@ static int netvsc_destroy_buf(struct netvsc_device *net_device)
 				   "unable to teardown send buffer's gpadl\n");
 			return ret;
 		}
-		net_device->recv_buf_gpadl_handle = 0;
+		net_device->send_buf_gpadl_handle = 0;
 	}
 	if (net_device->send_buf) {
 		/* Free up the receive buffer */
