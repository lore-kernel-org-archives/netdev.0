From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 08/26] iwlegacy: constify local structures
Date: Sun, 11 Sep 2016 15:05:50 +0200
Message-ID: <1473599168-30561-9-git-send-email-Julia.Lawall@lip6.fr>
References: <1473599168-30561-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: joe@perches.com, kernel-janitors@vger.kernel.org,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473599168-30561-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For structure types defined in the same file or local header files, find
top-level static structure declarations that have the following
properties:
1. Never reassigned.
2. Address never taken
3. Not passed to a top-level macro call
4. No pointer or array-typed field passed to a function or stored in a
variable.
Declare structures having all of these properties as const.

Done using Coccinelle.
Based on a suggestion by Joe Perches <joe@perches.com>.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
The semantic patch seems too long for a commit log, but is in the cover
letter.

 drivers/net/wireless/intel/iwlegacy/3945.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/intel/iwlegacy/3945.c b/drivers/net/wireless/intel/iwlegacy/3945.c
index 209dc99..4db327a 100644
--- a/drivers/net/wireless/intel/iwlegacy/3945.c
+++ b/drivers/net/wireless/intel/iwlegacy/3945.c
@@ -2671,7 +2671,7 @@ const struct il_ops il3945_ops = {
 	.send_led_cmd = il3945_send_led_cmd,
 };
 
-static struct il_cfg il3945_bg_cfg = {
+static const struct il_cfg il3945_bg_cfg = {
 	.name = "3945BG",
 	.fw_name_pre = IL3945_FW_PRE,
 	.ucode_api_max = IL3945_UCODE_API_MAX,
@@ -2700,7 +2700,7 @@ static struct il_cfg il3945_bg_cfg = {
 	},
 };
 
-static struct il_cfg il3945_abg_cfg = {
+static const struct il_cfg il3945_abg_cfg = {
 	.name = "3945ABG",
 	.fw_name_pre = IL3945_FW_PRE,
 	.ucode_api_max = IL3945_UCODE_API_MAX,
