From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 02/18] net/wireless: use generic_file_llseek in debugfs
Date: Wed,  7 Jul 2010 23:40:04 +0200
Message-ID: <1278538820-1392-3-git-send-email-arnd@arndb.de>
References: <1278538820-1392-1-git-send-email-arnd@arndb.de>
Cc: John Kacur <jkacur@redhat.com>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>, Christoph Hellwig <hch@lst.de>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1278538820-1392-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The default llseek operation is changing from
default_llseek to no_llseek, so all code relying on
the current behaviour needs to make that explicit.

The wireless driver infrastructure and some of the drivers
make use of generated debugfs files, so they cannot
be converted by our script that automatically determines
the right operation.

All these files use debugfs and they typically rely
on simple_read_from_buffer, so the best llseek operation
here is generic_file_llseek.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: "John W. Linville" <linville@tuxdriver.com>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 drivers/misc/iwmc3200top/debugfs.c           |    3 +++
 drivers/net/wireless/b43/debugfs.c           |    1 +
 drivers/net/wireless/b43legacy/debugfs.c     |    1 +
 drivers/net/wireless/iwlwifi/iwl-debugfs.c   |    3 +++
 drivers/net/wireless/libertas/debugfs.c      |    1 +
 drivers/net/wireless/rt2x00/rt2x00debug.c    |    1 +
 drivers/net/wireless/wl12xx/wl1251_debugfs.c |    2 ++
 drivers/net/wireless/wl12xx/wl1271_debugfs.c |    2 ++
 net/mac80211/debugfs.c                       |    2 ++
 net/mac80211/debugfs_key.c                   |    2 ++
 net/mac80211/debugfs_netdev.c                |    1 +
 net/mac80211/debugfs_sta.c                   |    2 ++
 net/wireless/debugfs.c                       |    1 +
 13 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/drivers/misc/iwmc3200top/debugfs.c b/drivers/misc/iwmc3200top/debugfs.c
index e9eda47..62fbaec 100644
--- a/drivers/misc/iwmc3200top/debugfs.c
+++ b/drivers/misc/iwmc3200top/debugfs.c
@@ -71,6 +71,7 @@ ssize_t iwmct_dbgfs_##name##_write(struct file *file,			\
 	static const struct file_operations iwmct_dbgfs_##name##_ops = {  \
 		.read = iwmct_dbgfs_##name##_read,			\
 		.open = iwmct_dbgfs_open_file_generic,			\
+		.llseek = generic_file_llseek,				\
 	};
 
 #define DEBUGFS_WRITE_FILE_OPS(name)					\
@@ -78,6 +79,7 @@ ssize_t iwmct_dbgfs_##name##_write(struct file *file,			\
 	static const struct file_operations iwmct_dbgfs_##name##_ops = {  \
 		.write = iwmct_dbgfs_##name##_write,			\
 		.open = iwmct_dbgfs_open_file_generic,			\
+		.llseek = generic_file_llseek,				\
 	};
 
 #define DEBUGFS_READ_WRITE_FILE_OPS(name)				\
@@ -87,6 +89,7 @@ ssize_t iwmct_dbgfs_##name##_write(struct file *file,			\
 		.write = iwmct_dbgfs_##name##_write,			\
 		.read = iwmct_dbgfs_##name##_read,			\
 		.open = iwmct_dbgfs_open_file_generic,			\
+		.llseek = generic_file_llseek,				\
 	};
 
 
diff --git a/drivers/net/wireless/b43/debugfs.c b/drivers/net/wireless/b43/debugfs.c
index 80b19a4..59f59fa 100644
--- a/drivers/net/wireless/b43/debugfs.c
+++ b/drivers/net/wireless/b43/debugfs.c
@@ -627,6 +627,7 @@ out_unlock:
 			.open	= b43_debugfs_open,		\
 			.read	= b43_debugfs_read,		\
 			.write	= b43_debugfs_write,		\
+			.llseek = generic_file_llseek,		\
 		},						\
 		.file_struct_offset = offsetof(struct b43_dfsentry, \
 					       file_##name),	\
diff --git a/drivers/net/wireless/b43legacy/debugfs.c b/drivers/net/wireless/b43legacy/debugfs.c
index 1f85ac5..f232618 100644
--- a/drivers/net/wireless/b43legacy/debugfs.c
+++ b/drivers/net/wireless/b43legacy/debugfs.c
@@ -334,6 +334,7 @@ out_unlock:
 			.open	= b43legacy_debugfs_open,		\
 			.read	= b43legacy_debugfs_read,		\
 			.write	= b43legacy_debugfs_write,		\
+			.llseek = generic_file_llseek,			\
 		},						\
 		.file_struct_offset = offsetof(struct b43legacy_dfsentry, \
 					       file_##name),	\
diff --git a/drivers/net/wireless/iwlwifi/iwl-debugfs.c b/drivers/net/wireless/iwlwifi/iwl-debugfs.c
index 9659c5d..0d03cf2 100644
--- a/drivers/net/wireless/iwlwifi/iwl-debugfs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-debugfs.c
@@ -87,6 +87,7 @@ static int iwl_dbgfs_open_file_generic(struct inode *inode, struct file *file)
 static const struct file_operations iwl_dbgfs_##name##_ops = {          \
 	.read = iwl_dbgfs_##name##_read,                       		\
 	.open = iwl_dbgfs_open_file_generic,                    	\
+	.llseek = generic_file_llseek,					\
 };
 
 #define DEBUGFS_WRITE_FILE_OPS(name)                                    \
@@ -94,6 +95,7 @@ static const struct file_operations iwl_dbgfs_##name##_ops = {          \
 static const struct file_operations iwl_dbgfs_##name##_ops = {          \
 	.write = iwl_dbgfs_##name##_write,                              \
 	.open = iwl_dbgfs_open_file_generic,                    	\
+	.llseek = generic_file_llseek,					\
 };
 
 
@@ -104,6 +106,7 @@ static const struct file_operations iwl_dbgfs_##name##_ops = {          \
 	.write = iwl_dbgfs_##name##_write,                              \
 	.read = iwl_dbgfs_##name##_read,                                \
 	.open = iwl_dbgfs_open_file_generic,                            \
+	.llseek = generic_file_llseek,					\
 };
 
 int iwl_dbgfs_statistics_flag(struct iwl_priv *priv, char *buf, int bufsz)
diff --git a/drivers/net/wireless/libertas/debugfs.c b/drivers/net/wireless/libertas/debugfs.c
index de2caac..94f8f99 100644
--- a/drivers/net/wireless/libertas/debugfs.c
+++ b/drivers/net/wireless/libertas/debugfs.c
@@ -713,6 +713,7 @@ out_unlock:
 	.open = open_file_generic, \
 	.read = (fread), \
 	.write = (fwrite), \
+	.llseek = generic_file_llseek, \
 }
 
 struct lbs_debugfs_files {
diff --git a/drivers/net/wireless/rt2x00/rt2x00debug.c b/drivers/net/wireless/rt2x00/rt2x00debug.c
index e9fe93f..fe92500 100644
--- a/drivers/net/wireless/rt2x00/rt2x00debug.c
+++ b/drivers/net/wireless/rt2x00/rt2x00debug.c
@@ -508,6 +508,7 @@ static const struct file_operations rt2x00debug_fop_##__name = {\
 	.write		= rt2x00debug_write_##__name,		\
 	.open		= rt2x00debug_file_open,		\
 	.release	= rt2x00debug_file_release,		\
+	.llseek		= generic_file_llseek,			\
 };
 
 RT2X00DEBUGFS_OPS(csr, "0x%.8x\n", u32);
diff --git a/drivers/net/wireless/wl12xx/wl1251_debugfs.c b/drivers/net/wireless/wl12xx/wl1251_debugfs.c
index 5e4465a..a4ae7c4 100644
--- a/drivers/net/wireless/wl12xx/wl1251_debugfs.c
+++ b/drivers/net/wireless/wl12xx/wl1251_debugfs.c
@@ -50,6 +50,7 @@ static ssize_t name## _read(struct file *file, char __user *userbuf,	\
 static const struct file_operations name## _ops = {			\
 	.read = name## _read,						\
 	.open = wl1251_open_file_generic,				\
+	.llseek	= generic_file_llseek,					\
 };
 
 #define DEBUGFS_ADD(name, parent)					\
@@ -86,6 +87,7 @@ static ssize_t sub## _ ##name## _read(struct file *file,		\
 static const struct file_operations sub## _ ##name## _ops = {		\
 	.read = sub## _ ##name## _read,					\
 	.open = wl1251_open_file_generic,				\
+	.llseek	= generic_file_llseek,					\
 };
 
 #define DEBUGFS_FWSTATS_ADD(sub, name)				\
diff --git a/drivers/net/wireless/wl12xx/wl1271_debugfs.c b/drivers/net/wireless/wl12xx/wl1271_debugfs.c
index c239ef4..6e25303 100644
--- a/drivers/net/wireless/wl12xx/wl1271_debugfs.c
+++ b/drivers/net/wireless/wl12xx/wl1271_debugfs.c
@@ -51,6 +51,7 @@ static ssize_t name## _read(struct file *file, char __user *userbuf,	\
 static const struct file_operations name## _ops = {			\
 	.read = name## _read,						\
 	.open = wl1271_open_file_generic,				\
+	.llseek	= generic_file_llseek,					\
 };
 
 #define DEBUGFS_ADD(name, parent)					\
@@ -87,6 +88,7 @@ static ssize_t sub## _ ##name## _read(struct file *file,		\
 static const struct file_operations sub## _ ##name## _ops = {		\
 	.read = sub## _ ##name## _read,					\
 	.open = wl1271_open_file_generic,				\
+	.llseek	= generic_file_llseek,					\
 };
 
 #define DEBUGFS_FWSTATS_ADD(sub, name)				\
diff --git a/net/mac80211/debugfs.c b/net/mac80211/debugfs.c
index 637929b..31b6b89 100644
--- a/net/mac80211/debugfs.c
+++ b/net/mac80211/debugfs.c
@@ -36,6 +36,7 @@ static ssize_t name## _read(struct file *file, char __user *userbuf,	\
 static const struct file_operations name## _ops = {			\
 	.read = name## _read,						\
 	.open = mac80211_open_file_generic,				\
+	.llseek = generic_file_llseek,					\
 };
 
 #define DEBUGFS_ADD(name)						\
@@ -349,6 +350,7 @@ static ssize_t stats_ ##name## _read(struct file *file,			\
 static const struct file_operations stats_ ##name## _ops = {		\
 	.read = stats_ ##name## _read,					\
 	.open = mac80211_open_file_generic,				\
+	.llseek = generic_file_llseek,					\
 };
 
 #define DEBUGFS_STATS_ADD(name)						\
diff --git a/net/mac80211/debugfs_key.c b/net/mac80211/debugfs_key.c
index 97c9e46..1bc39ac 100644
--- a/net/mac80211/debugfs_key.c
+++ b/net/mac80211/debugfs_key.c
@@ -32,6 +32,7 @@ static ssize_t key_##name##_read(struct file *file,			\
 static const struct file_operations key_ ##name## _ops = {		\
 	.read = key_##name##_read,					\
 	.open = mac80211_open_file_generic,				\
+	.llseek = generic_file_llseek,					\
 }
 
 #define KEY_FILE(name, format)						\
@@ -46,6 +47,7 @@ static const struct file_operations key_ ##name## _ops = {		\
 static const struct file_operations key_ ##name## _ops = {		\
 	.read = key_conf_##name##_read,					\
 	.open = mac80211_open_file_generic,				\
+	.llseek = generic_file_llseek,					\
 }
 
 #define KEY_CONF_FILE(name, format)					\
diff --git a/net/mac80211/debugfs_netdev.c b/net/mac80211/debugfs_netdev.c
index 20b2998..8ad33ee 100644
--- a/net/mac80211/debugfs_netdev.c
+++ b/net/mac80211/debugfs_netdev.c
@@ -121,6 +121,7 @@ static const struct file_operations name##_ops = {			\
 	.read = ieee80211_if_read_##name,				\
 	.write = (_write),						\
 	.open = mac80211_open_file_generic,				\
+	.llseek = generic_file_llseek,					\
 }
 
 #define __IEEE80211_IF_FILE_W(name)					\
diff --git a/net/mac80211/debugfs_sta.c b/net/mac80211/debugfs_sta.c
index e763f15..73f8f36 100644
--- a/net/mac80211/debugfs_sta.c
+++ b/net/mac80211/debugfs_sta.c
@@ -37,6 +37,7 @@ static ssize_t sta_ ##name## _read(struct file *file,			\
 static const struct file_operations sta_ ##name## _ops = {		\
 	.read = sta_##name##_read,					\
 	.open = mac80211_open_file_generic,				\
+	.llseek = generic_file_llseek,					\
 }
 
 #define STA_OPS_RW(name)						\
@@ -44,6 +45,7 @@ static const struct file_operations sta_ ##name## _ops = {		\
 	.read = sta_##name##_read,					\
 	.write = sta_##name##_write,					\
 	.open = mac80211_open_file_generic,				\
+	.llseek = generic_file_llseek,					\
 }
 
 #define STA_FILE(name, field, format)					\
diff --git a/net/wireless/debugfs.c b/net/wireless/debugfs.c
index a4991a3..3f9a57e 100644
--- a/net/wireless/debugfs.c
+++ b/net/wireless/debugfs.c
@@ -34,6 +34,7 @@ static ssize_t name## _read(struct file *file, char __user *userbuf,	\
 static const struct file_operations name## _ops = {			\
 	.read = name## _read,						\
 	.open = cfg80211_open_file_generic,				\
+	.llseek = generic_file_llseek,					\
 };
 
 DEBUGFS_READONLY_FILE(rts_threshold, 20, "%d",
-- 
1.7.1
