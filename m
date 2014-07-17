From: Andrey Utkin <andrey.krieger.utkin@gmail.com>
Subject: [PATCH 4/4] ath9k: drop negativity checks for unsigned values coming from kstrtoul()
Date: Thu, 17 Jul 2014 16:56:37 +0300
Message-ID: <1405605397-13749-1-git-send-email-andrey.krieger.utkin@gmail.com>
Cc: linville@tuxdriver.com,
	Andrey Utkin <andrey.krieger.utkin@gmail.com>
To: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	linux-wireless@vger.kernel.org, ath9k-devel@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=80471
Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=80481
Reported-by: David Binderman <dcb314@hotmail.com>
Signed-off-by: Andrey Utkin <andrey.krieger.utkin@gmail.com>
---
 drivers/net/wireless/ath/ath9k/debug.c    | 2 +-
 drivers/net/wireless/ath/ath9k/spectral.c | 8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/debug.c b/drivers/net/wireless/ath/ath9k/debug.c
index ce073e9..d227936 100644
--- a/drivers/net/wireless/ath/ath9k/debug.c
+++ b/drivers/net/wireless/ath/ath9k/debug.c
@@ -202,7 +202,7 @@ static ssize_t write_file_ani(struct file *file,
 	if (kstrtoul(buf, 0, &ani))
 		return -EINVAL;
 
-	if (ani < 0 || ani > 1)
+	if (ani > 1)
 		return -EINVAL;
 
 	common->disable_ani = !ani;
diff --git a/drivers/net/wireless/ath/ath9k/spectral.c b/drivers/net/wireless/ath/ath9k/spectral.c
index 99f4de9..5fe29b9 100644
--- a/drivers/net/wireless/ath/ath9k/spectral.c
+++ b/drivers/net/wireless/ath/ath9k/spectral.c
@@ -313,7 +313,7 @@ static ssize_t write_file_spectral_short_repeat(struct file *file,
 	if (kstrtoul(buf, 0, &val))
 		return -EINVAL;
 
-	if (val < 0 || val > 1)
+	if (val > 1)
 		return -EINVAL;
 
 	sc->spec_config.short_repeat = val;
@@ -361,7 +361,7 @@ static ssize_t write_file_spectral_count(struct file *file,
 	if (kstrtoul(buf, 0, &val))
 		return -EINVAL;
 
-	if (val < 0 || val > 255)
+	if (val > 255)
 		return -EINVAL;
 
 	sc->spec_config.count = val;
@@ -409,7 +409,7 @@ static ssize_t write_file_spectral_period(struct file *file,
 	if (kstrtoul(buf, 0, &val))
 		return -EINVAL;
 
-	if (val < 0 || val > 255)
+	if (val > 255)
 		return -EINVAL;
 
 	sc->spec_config.period = val;
@@ -457,7 +457,7 @@ static ssize_t write_file_spectral_fft_period(struct file *file,
 	if (kstrtoul(buf, 0, &val))
 		return -EINVAL;
 
-	if (val < 0 || val > 15)
+	if (val > 15)
 		return -EINVAL;
 
 	sc->spec_config.fft_period = val;
-- 
1.8.5.5
