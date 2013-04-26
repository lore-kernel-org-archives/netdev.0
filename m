From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next] hyperv: Fix a compiler warning in netvsc_send()
Date: Fri, 26 Apr 2013 11:25:55 -0700
Message-ID: <1367000755-2571-1-git-send-email-haiyangz@microsoft.com>
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed: warning: cast from pointer to integer of different size

The Hyper-V hosts always use 64 bit request id. The guests can have 32 or 64
bit pointers which equal to the ulong type size. So we cast it to ulong type.
And, assigning 32bit integer to 64 bit variable works fine.

The VMBus returns the same id in the completion packet. But the value has no
effect on the host side.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/netvsc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index f5f0f09..2b04804 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -522,7 +522,7 @@ int netvsc_send(struct hv_device *device,
 	sendMessage.msg.v1_msg.send_rndis_pkt.send_buf_section_size = 0;
 
 	if (packet->completion.send.send_completion)
-		req_id = (u64)packet;
+		req_id = (ulong)packet;
 	else
 		req_id = 0;
 
-- 
1.7.4.1
