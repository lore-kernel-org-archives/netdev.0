From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 2.6.11-rc4-netdev1 3/4] ieee80211: C99 initialization for eap_types
Date: Mon, 14 Feb 2005 00:27:29 +0100
Message-ID: <20050213232729.GB2898@electric-eye.fr.zoreil.com>
References: <420FBAD3.3020909@pobox.com> <20050213232421.GB2060@electric-eye.fr.zoreil.com> <20050213232559.GA2898@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Stephen Hemminger <shemminger@osdl.org>,
        Randy Dunlap <rddunlap@osdl.org>,
        James Ketrenos <jketreno@linux.intel.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050213232559.GA2898@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

C99 initialization for eap_types.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN include/net/ieee80211.h~80211-020 include/net/ieee80211.h
--- a/include/net/ieee80211.h~80211-020	2005-02-14 00:10:49.003115207 +0100
+++ b/include/net/ieee80211.h	2005-02-14 00:10:49.007114556 +0100
@@ -64,16 +64,25 @@ struct ieee80211_hdr_3addr {
 	u16 seq_ctl;
 } __attribute__ ((packed));
 
+enum eap_type {
+	EAP_PACKET = 0,
+	EAPOL_START,
+	EAPOL_LOGOFF,
+	EAPOL_KEY,
+	EAPOL_ENCAP_ASF_ALERT
+};
+
 static const char *eap_types[] = {
-	"EAP-Packet", "EAPOL-Start", "EAPOL-Logoff", "EAPOL-Key",
-	"EAPOL-Encap-ASF-Alert", "Unknown"
+	[EAP_PACKET]		= "EAP-Packet",
+	[EAPOL_START]		= "EAPOL-Start",
+	[EAPOL_LOGOFF]		= "EAPOL-Logoff",
+	[EAPOL_KEY]		= "EAPOL-Key",
+	[EAPOL_ENCAP_ASF_ALERT]	= "EAPOL-Encap-ASF-Alert"
 };
 
 static inline const char *eap_get_type(int type)
 {
-	if (type > ARRAY_SIZE(eap_types))
-		type = ARRAY_SIZE(eap_types) - 1;
-	return eap_types[type];
+	return (type >= ARRAY_SIZE(eap_types)) ? "Unknown" : eap_types[type];
 }
 
 struct eapol {

_
