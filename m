From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: [PATCH]hostap:hostap_ioctl.c Fix variable 'hostscan' set but not used
Date: Mon,  2 Aug 2010 17:04:39 -0700
Message-ID: <1280793879-1768-1-git-send-email-justinmattock@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, j@w1.fi,
	linville@tuxdriver.com,
	"Justin P. Mattock" <justinmattock@gmail.com>
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch below fixes a compiler warning:
  CC [M]  drivers/net/wireless/hostap/hostap_ioctl.o
drivers/net/wireless/hostap/hostap_ioctl.c: In function 'prism2_translate_scan':
drivers/net/wireless/hostap/hostap_ioctl.c:1954:13: warning: variable 'hostscan' set but not used

Keep in mind I've looked and searched for a fix for this but
couldnt come up with anything.(if there is let me know and I'll have a try at it). 

Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>

---
 drivers/net/wireless/hostap/hostap_ioctl.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_ioctl.c b/drivers/net/wireless/hostap/hostap_ioctl.c
index 27d462f..25420e3 100644
--- a/drivers/net/wireless/hostap/hostap_ioctl.c
+++ b/drivers/net/wireless/hostap/hostap_ioctl.c
@@ -1951,7 +1951,7 @@ static inline int prism2_translate_scan(local_info_t *local,
 					char *buffer, int buflen)
 {
 	struct hfa384x_hostscan_result *scan;
-	int entry, hostscan;
+	int entry;
 	char *current_ev = buffer;
 	char *end_buf = buffer + buflen;
 	struct list_head *ptr;
@@ -1964,7 +1964,6 @@ static inline int prism2_translate_scan(local_info_t *local,
 		bss->included = 0;
 	}
 
-	hostscan = local->last_scan_type == PRISM2_HOSTSCAN;
 	for (entry = 0; entry < local->last_scan_results_count; entry++) {
 		int found = 0;
 		scan = &local->last_scan_results[entry];
-- 
1.7.1.rc1.21.gf3bd6
