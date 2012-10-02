From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next,2/6] hyperv: Fix the missing return value in rndis_filter_set_packet_filter()
Date: Tue,  2 Oct 2012 08:30:20 -0700
Message-ID: <1349191824-14001-2-git-send-email-haiyangz@microsoft.com>
References: <1349191824-14001-1-git-send-email-haiyangz@microsoft.com>
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349191824-14001-1-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Return ETIMEDOUT when the reply message is not received in time.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

---
 drivers/net/hyperv/rndis_filter.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 1337b64..617eb2e 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -647,6 +647,7 @@ int rndis_filter_set_packet_filter(struct rndis_device *dev, u32 new_filter)
 	if (t == 0) {
 		netdev_err(ndev,
 			"timeout before we got a set response...\n");
+		ret = -ETIMEDOUT;
 		/*
 		 * We can't deallocate the request since we may still receive a
 		 * send completion for it.
-- 
1.7.4.1
