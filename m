From: Kirtika Ruchandani <kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/5] ath10k: Remove unused 'num_vdev_stats' variable
Date: Thu, 24 Nov 2016 00:01:41 -0800
Message-ID: <053542094d16965b971f1bc70dbbe9dff3c40ca1.1479974100.git.kirtika@chromium.org>
References: <cover.1479974100.git.kirtika@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Raja Mani <rmani-Rm6X0d1/PG5y9aJCnZT0Uw@public.gmane.org>,
        Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
To: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <cover.1479974100.git.kirtika-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Several functions for wmi stats parsing define and set num_vdev_stats
but do not use it. Compiling with W=1 gives the following warnings,
fix them.

drivers/net/wireless/ath/ath10k/wmi.c: In function ‘ath10k_wmi_main_op_pull_fw_stats’:
drivers/net/wireless/ath/ath10k/wmi.c:2680:22: warning: variable ‘num_vdev_stats’ set but not used [-Wunused-but-set-variable]
  u32 num_pdev_stats, num_vdev_stats, num_peer_stats;
                      ^
drivers/net/wireless/ath/ath10k/wmi.c: In function ‘ath10k_wmi_10x_op_pull_fw_stats’:
drivers/net/wireless/ath/ath10k/wmi.c:2735:22: warning: variable ‘num_vdev_stats’ set but not used [-Wunused-but-set-variable]
  u32 num_pdev_stats, num_vdev_stats, num_peer_stats;
                      ^
drivers/net/wireless/ath/ath10k/wmi.c: In function ‘ath10k_wmi_10_2_op_pull_fw_stats’:
drivers/net/wireless/ath/ath10k/wmi.c:2796:6: warning: variable ‘num_vdev_stats’ set but not used [-Wunused-but-set-variable]
  u32 num_vdev_stats;
      ^
drivers/net/wireless/ath/ath10k/wmi.c: In function ‘ath10k_wmi_10_2_4_op_pull_fw_stats’:
drivers/net/wireless/ath/ath10k/wmi.c:2875:6: warning: variable ‘num_vdev_stats’ set but not used [-Wunused-but-set-variable]
  u32 num_vdev_stats;
      ^
drivers/net/wireless/ath/ath10k/wmi.c: In function ‘ath10k_wmi_10_4_op_pull_fw_stats’:
drivers/net/wireless/ath/ath10k/wmi.c:2963:6: warning: variable ‘num_vdev_stats’ set but not used [-Wunused-but-set-variable]
  u32 num_vdev_stats;
      ^

These are harmless warnings and are only being fixed to reduce the
noise with W=1 in the kernel.

Fixes: d15fb5200664 ("ath10k: split wmi stats parsing")
Fixes: 20de2229c634 ("ath10k: fix 10.2 fw stats parsing")
Cc: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
Cc: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Signed-off-by: Kirtika Ruchandani <kirtika-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
---
 drivers/net/wireless/ath/ath10k/wmi.c | 12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/wmi.c b/drivers/net/wireless/ath/ath10k/wmi.c
index 1f28187..10ec5a5 100644
--- a/drivers/net/wireless/ath/ath10k/wmi.c
+++ b/drivers/net/wireless/ath/ath10k/wmi.c
@@ -2675,14 +2675,13 @@ static int ath10k_wmi_main_op_pull_fw_stats(struct ath10k *ar,
					    struct ath10k_fw_stats *stats)
 {
	const struct wmi_stats_event *ev = (void *)skb->data;
-	u32 num_pdev_stats, num_vdev_stats, num_peer_stats;
+	u32 num_pdev_stats, num_peer_stats;
	int i;

	if (!skb_pull(skb, sizeof(*ev)))
		return -EPROTO;

	num_pdev_stats = __le32_to_cpu(ev->num_pdev_stats);
-	num_vdev_stats = __le32_to_cpu(ev->num_vdev_stats);
	num_peer_stats = __le32_to_cpu(ev->num_peer_stats);

	for (i = 0; i < num_pdev_stats; i++) {
@@ -2730,14 +2729,13 @@ static int ath10k_wmi_10x_op_pull_fw_stats(struct ath10k *ar,
					   struct ath10k_fw_stats *stats)
 {
	const struct wmi_stats_event *ev = (void *)skb->data;
-	u32 num_pdev_stats, num_vdev_stats, num_peer_stats;
+	u32 num_pdev_stats, num_peer_stats;
	int i;

	if (!skb_pull(skb, sizeof(*ev)))
		return -EPROTO;

	num_pdev_stats = __le32_to_cpu(ev->num_pdev_stats);
-	num_vdev_stats = __le32_to_cpu(ev->num_vdev_stats);
	num_peer_stats = __le32_to_cpu(ev->num_peer_stats);

	for (i = 0; i < num_pdev_stats; i++) {
@@ -2791,7 +2789,6 @@ static int ath10k_wmi_10_2_op_pull_fw_stats(struct ath10k *ar,
	const struct wmi_10_2_stats_event *ev = (void *)skb->data;
	u32 num_pdev_stats;
	u32 num_pdev_ext_stats;
-	u32 num_vdev_stats;
	u32 num_peer_stats;
	int i;

@@ -2800,7 +2797,6 @@ static int ath10k_wmi_10_2_op_pull_fw_stats(struct ath10k *ar,

	num_pdev_stats = __le32_to_cpu(ev->num_pdev_stats);
	num_pdev_ext_stats = __le32_to_cpu(ev->num_pdev_ext_stats);
-	num_vdev_stats = __le32_to_cpu(ev->num_vdev_stats);
	num_peer_stats = __le32_to_cpu(ev->num_peer_stats);

	for (i = 0; i < num_pdev_stats; i++) {
@@ -2870,7 +2866,6 @@ static int ath10k_wmi_10_2_4_op_pull_fw_stats(struct ath10k *ar,
	const struct wmi_10_2_stats_event *ev = (void *)skb->data;
	u32 num_pdev_stats;
	u32 num_pdev_ext_stats;
-	u32 num_vdev_stats;
	u32 num_peer_stats;
	int i;

@@ -2879,7 +2874,6 @@ static int ath10k_wmi_10_2_4_op_pull_fw_stats(struct ath10k *ar,

	num_pdev_stats = __le32_to_cpu(ev->num_pdev_stats);
	num_pdev_ext_stats = __le32_to_cpu(ev->num_pdev_ext_stats);
-	num_vdev_stats = __le32_to_cpu(ev->num_vdev_stats);
	num_peer_stats = __le32_to_cpu(ev->num_peer_stats);

	for (i = 0; i < num_pdev_stats; i++) {
@@ -2958,7 +2952,6 @@ static int ath10k_wmi_10_4_op_pull_fw_stats(struct ath10k *ar,
	const struct wmi_10_2_stats_event *ev = (void *)skb->data;
	u32 num_pdev_stats;
	u32 num_pdev_ext_stats;
-	u32 num_vdev_stats;
	u32 num_peer_stats;
	u32 num_bcnflt_stats;
	u32 stats_id;
@@ -2969,7 +2962,6 @@ static int ath10k_wmi_10_4_op_pull_fw_stats(struct ath10k *ar,

	num_pdev_stats = __le32_to_cpu(ev->num_pdev_stats);
	num_pdev_ext_stats = __le32_to_cpu(ev->num_pdev_ext_stats);
-	num_vdev_stats = __le32_to_cpu(ev->num_vdev_stats);
	num_peer_stats = __le32_to_cpu(ev->num_peer_stats);
	num_bcnflt_stats = __le32_to_cpu(ev->num_bcnflt_stats);
	stats_id = __le32_to_cpu(ev->stats_id);
--
2.8.0.rc3.226.g39d4020
