From: gregkh@suse.de
Subject: [patch 24/26] hostap: Fix EAPOL frame encryption
Date: Tue, 4 Apr 2006 17:01:18 -0700
Message-ID: <20060405000118.GY27049@kroah.com>
References: <20060404235634.696852000@quad.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Theodore Ts'o <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>, torvalds@osdl.org,
	akpm@osdl.org, alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	Jouni Malinen <jkmaline@cc.hut.fi>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751002AbWDEADc@vger.kernel.org>
To: linux-kernel@vger.kernel.org, stable@kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline; filename="hostap_fix_eapol_crypt.patch"
In-Reply-To: <20060404235927.GA27049@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed encrypted of EAPOL frames from wlan#ap interface (hostapd). This
was broken when moving to use new frame control field defines in
net/ieee80211.h. hostapd uses Protected flag, not protocol version
(which was cleared in this function anyway). This fixes WPA group key
handshake and re-authentication.
http://hostap.epitest.fi/bugz/show_bug.cgi?id=126

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>


---
 drivers/net/wireless/hostap/hostap_80211_tx.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.16.1.orig/drivers/net/wireless/hostap/hostap_80211_tx.c
+++ linux-2.6.16.1/drivers/net/wireless/hostap/hostap_80211_tx.c
@@ -469,7 +469,7 @@ int hostap_master_start_xmit(struct sk_b
 	}
 
 	if (local->ieee_802_1x && meta->ethertype == ETH_P_PAE && tx.crypt &&
-	    !(fc & IEEE80211_FCTL_VERS)) {
+	    !(fc & IEEE80211_FCTL_PROTECTED)) {
 		no_encrypt = 1;
 		PDEBUG(DEBUG_EXTRA2, "%s: TX: IEEE 802.1X - passing "
 		       "unencrypted EAPOL frame\n", dev->name);

--
