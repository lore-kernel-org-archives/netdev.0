From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 2.6.11-rc4-netdev1 1/4] ieee80211: failure of ieee80211_crypto_init()
Date: Mon, 14 Feb 2005 00:24:21 +0100
Message-ID: <20050213232421.GB2060@electric-eye.fr.zoreil.com>
References: <420FBAD3.3020909@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Stephen Hemminger <shemminger@osdl.org>,
        Randy Dunlap <rddunlap@osdl.org>,
        James Ketrenos <jketreno@linux.intel.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <420FBAD3.3020909@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Tell the world that ieee80211_crypto_init() failed and propagate its
status code.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN net/ieee80211/ieee80211_crypt.c~80211-000 net/ieee80211/ieee80211_crypt.c
--- a/net/ieee80211/ieee80211_crypt.c~80211-000	2005-02-13 23:38:22.751792758 +0100
+++ b/net/ieee80211/ieee80211_crypt.c	2005-02-13 23:38:22.762790957 +0100
@@ -207,17 +207,23 @@ static struct ieee80211_crypto_ops ieee8
 
 static int __init ieee80211_crypto_init(void)
 {
+	int ret = -ENOMEM;
+
 	hcrypt = kmalloc(sizeof(*hcrypt), GFP_KERNEL);
-	if (hcrypt == NULL)
-		return -ENOMEM;
+	if (!hcrypt)
+		goto out;
 
 	memset(hcrypt, 0, sizeof(*hcrypt));
 	INIT_LIST_HEAD(&hcrypt->algs);
 	spin_lock_init(&hcrypt->lock);
 
-	(void) ieee80211_register_crypto_ops(&ieee80211_crypt_null);
-
-	return 0;
+	ret = ieee80211_register_crypto_ops(&ieee80211_crypt_null);
+	if (ret < 0) {
+		kfree(hcrypt);
+		hcrypt = NULL;
+	}
+out:
+	return ret;
 }
 
 
diff -puN net/ieee80211/ieee80211_crypt_ccmp.c~80211-000 net/ieee80211/ieee80211_crypt_ccmp.c
--- a/net/ieee80211/ieee80211_crypt_ccmp.c~80211-000	2005-02-13 23:38:22.754792267 +0100
+++ b/net/ieee80211/ieee80211_crypt_ccmp.c	2005-02-13 23:38:22.763790793 +0100
@@ -456,10 +456,7 @@ static struct ieee80211_crypto_ops ieee8
 
 static int __init ieee80211_crypto_ccmp_init(void)
 {
-	if (ieee80211_register_crypto_ops(&ieee80211_crypt_ccmp) < 0)
-		return -1;
-
-	return 0;
+	return ieee80211_register_crypto_ops(&ieee80211_crypt_ccmp);
 }
 
 
diff -puN net/ieee80211/ieee80211_crypt_tkip.c~80211-000 net/ieee80211/ieee80211_crypt_tkip.c
--- a/net/ieee80211/ieee80211_crypt_tkip.c~80211-000	2005-02-13 23:38:22.757791776 +0100
+++ b/net/ieee80211/ieee80211_crypt_tkip.c	2005-02-13 23:38:22.764790629 +0100
@@ -694,10 +694,7 @@ static struct ieee80211_crypto_ops ieee8
 
 static int __init ieee80211_crypto_tkip_init(void)
 {
-	if (ieee80211_register_crypto_ops(&ieee80211_crypt_tkip) < 0)
-		return -1;
-
-	return 0;
+	return ieee80211_register_crypto_ops(&ieee80211_crypt_tkip);
 }
 
 
diff -puN net/ieee80211/ieee80211_crypt_wep.c~80211-000 net/ieee80211/ieee80211_crypt_wep.c
--- a/net/ieee80211/ieee80211_crypt_wep.c~80211-000	2005-02-13 23:38:22.759791448 +0100
+++ b/net/ieee80211/ieee80211_crypt_wep.c	2005-02-13 23:38:22.764790629 +0100
@@ -258,10 +258,7 @@ static struct ieee80211_crypto_ops ieee8
 
 static int __init ieee80211_crypto_wep_init(void)
 {
-	if (ieee80211_register_crypto_ops(&ieee80211_crypt_wep) < 0)
-		return -1;
-
-	return 0;
+	return ieee80211_register_crypto_ops(&ieee80211_crypt_wep);
 }
 
 

_
