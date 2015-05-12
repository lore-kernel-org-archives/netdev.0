From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] carl9170: match wait_for_completion_timeout return type
Date: Tue, 12 May 2015 20:18:38 +0200
Message-ID: <1431454718-23701-1-git-send-email-hofrat@osadl.org>
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicholas Mc Guire <hofrat@osadl.org>
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Return type of wait_for_completion_timeout is unsigned long not int.
An appropriately named unsigned long is added, and the assignments
as well as error checking fixed up.

API conformance testing for completions with coccinelle spatches are being
used to locate API usage inconsistencies:
./drivers/net/wireless/ath/carl9170/usb.c:675 
	int return assigned to unsigned long

Patch was compile tested with x86_64_defconfig + CONFIG_ATH_CARDS=m,
CONFIG_CARL9170=m

Patch is against 4.1-rc3 (localversion-next is -next-20150512)

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---
 drivers/net/wireless/ath/carl9170/usb.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/carl9170/usb.c b/drivers/net/wireless/ath/carl9170/usb.c
index c9f9331..76842e6 100644
--- a/drivers/net/wireless/ath/carl9170/usb.c
+++ b/drivers/net/wireless/ath/carl9170/usb.c
@@ -651,6 +651,7 @@ int carl9170_exec_cmd(struct ar9170 *ar, const enum carl9170_cmd_oids cmd,
 	unsigned int plen, void *payload, unsigned int outlen, void *out)
 {
 	int err = -ENOMEM;
+	unsigned long time_left;
 
 	if (!IS_ACCEPTING_CMD(ar))
 		return -EIO;
@@ -672,8 +673,8 @@ int carl9170_exec_cmd(struct ar9170 *ar, const enum carl9170_cmd_oids cmd,
 	err = __carl9170_exec_cmd(ar, &ar->cmd, false);
 
 	if (!(cmd & CARL9170_CMD_ASYNC_FLAG)) {
-		err = wait_for_completion_timeout(&ar->cmd_wait, HZ);
-		if (err == 0) {
+		time_left = wait_for_completion_timeout(&ar->cmd_wait, HZ);
+		if (time_left == 0) {
 			err = -ETIMEDOUT;
 			goto err_unbuf;
 		}
-- 
1.7.10.4
