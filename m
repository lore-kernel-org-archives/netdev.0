From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] ath9k_htc: match wait_for_completion_timeout return type
Date: Thu, 14 May 2015 17:29:54 +0200
Message-ID: <1431617394-30725-1-git-send-email-hofrat@osadl.org>
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	ath9k-devel@venema.h4ckr.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Nicholas Mc Guire <hofrat@osadl.org>
To: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Return type of wait_for_completion_timeout is unsigned long not int.
As time_left is exclusively used for wait_for_completion_timeout here its
type is simply changed to unsigned long.

API conformance testing for completions with coccinelle spatches are being
used to locate API usage inconsistencies:
./drivers/net/wireless/ath/ath9k/htc_hst.c:171
	int return assigned to unsigned long
./drivers/net/wireless/ath/ath9k/htc_hst.c:277
	int return assigned to unsigned long
./drivers/net/wireless/ath/ath9k/htc_hst.c:206
	int return assigned to unsigned long

Patch was compile tested with x86_64_defconfig + CONFIG_ATH_CARDS=m,
CONFIG_ATH9K_HTC=m

Patch is against 4.1-rc3 (localversion-next is -next-20150514)


Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---
 drivers/net/wireless/ath/ath9k/htc_hst.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/htc_hst.c b/drivers/net/wireless/ath/ath9k/htc_hst.c
index d2408da..2294709 100644
--- a/drivers/net/wireless/ath/ath9k/htc_hst.c
+++ b/drivers/net/wireless/ath/ath9k/htc_hst.c
@@ -146,7 +146,8 @@ static int htc_config_pipe_credits(struct htc_target *target)
 {
 	struct sk_buff *skb;
 	struct htc_config_pipe_msg *cp_msg;
-	int ret, time_left;
+	int ret;
+	unsigned long time_left;
 
 	skb = alloc_skb(50 + sizeof(struct htc_frame_hdr), GFP_ATOMIC);
 	if (!skb) {
@@ -184,7 +185,8 @@ static int htc_setup_complete(struct htc_target *target)
 {
 	struct sk_buff *skb;
 	struct htc_comp_msg *comp_msg;
-	int ret = 0, time_left;
+	int ret = 0;
+	unsigned long time_left;
 
 	skb = alloc_skb(50 + sizeof(struct htc_frame_hdr), GFP_ATOMIC);
 	if (!skb) {
@@ -236,7 +238,8 @@ int htc_connect_service(struct htc_target *target,
 	struct sk_buff *skb;
 	struct htc_endpoint *endpoint;
 	struct htc_conn_svc_msg *conn_msg;
-	int ret, time_left;
+	int ret;
+	unsigned long time_left;
 
 	/* Find an available endpoint */
 	endpoint = get_next_avail_ep(target->endpoint);
-- 
1.7.10.4
