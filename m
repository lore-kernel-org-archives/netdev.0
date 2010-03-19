From: Joe Perches <joe@perches.com>
Subject: [PATCH v3 7/9] drivers/net: Remove local #define IW_IOCTL,
	use IW_HANDLER
Date: Thu, 18 Mar 2010 18:29:38 -0700
Message-ID: <750b3579f93b78508d8ed8ccf7c3636db7e7e074.1268961559.git.joe@perches.com>
References: <cover.1268961559.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Zhu Yi <yi.zhu@intel.com>, Reinette Chatre <reinette.chatre@intel.com>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Intel Linux Wireless <ilw@linux.intel.com>, linuxppc-dev@ozlabs.org,
	Johannes Berg <johannes@sipsolutions.net>,
	Richard Kennedy <richard@rsk.demon.co.uk>, cbe-oss-dev@ozlabs.org
To: linux-kernel@vger.kernel.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <cover.1268961559.git.joe@perches.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

Use #define IW_HANDLER from wireless.h instead

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ps3_gelic_wireless.c       |   35 +++++++-------
 drivers/net/wireless/ipw2x00/ipw2200.c |   83 ++++++++++++++++----------------
 2 files changed, 58 insertions(+), 60 deletions(-)

diff --git a/drivers/net/ps3_gelic_wireless.c b/drivers/net/ps3_gelic_wireless.c
index 2663b2f..f5fc0f7 100644
--- a/drivers/net/ps3_gelic_wireless.c
+++ b/drivers/net/ps3_gelic_wireless.c
@@ -2279,26 +2279,25 @@ void gelic_wl_interrupt(struct net_device *netdev, u64 status)
 /*
  * driver helpers
  */
-#define IW_IOCTL(n) [(n) - SIOCSIWCOMMIT]
 static const iw_handler gelic_wl_wext_handler[] =
 {
-	IW_IOCTL(SIOCGIWNAME)		= gelic_wl_get_name,
-	IW_IOCTL(SIOCGIWRANGE)		= gelic_wl_get_range,
-	IW_IOCTL(SIOCSIWSCAN)		= gelic_wl_set_scan,
-	IW_IOCTL(SIOCGIWSCAN)		= gelic_wl_get_scan,
-	IW_IOCTL(SIOCSIWAUTH)		= gelic_wl_set_auth,
-	IW_IOCTL(SIOCGIWAUTH)		= gelic_wl_get_auth,
-	IW_IOCTL(SIOCSIWESSID)		= gelic_wl_set_essid,
-	IW_IOCTL(SIOCGIWESSID)		= gelic_wl_get_essid,
-	IW_IOCTL(SIOCSIWENCODE)		= gelic_wl_set_encode,
-	IW_IOCTL(SIOCGIWENCODE)		= gelic_wl_get_encode,
-	IW_IOCTL(SIOCSIWAP)		= gelic_wl_set_ap,
-	IW_IOCTL(SIOCGIWAP)		= gelic_wl_get_ap,
-	IW_IOCTL(SIOCSIWENCODEEXT)	= gelic_wl_set_encodeext,
-	IW_IOCTL(SIOCGIWENCODEEXT)	= gelic_wl_get_encodeext,
-	IW_IOCTL(SIOCSIWMODE)		= gelic_wl_set_mode,
-	IW_IOCTL(SIOCGIWMODE)		= gelic_wl_get_mode,
-	IW_IOCTL(SIOCGIWNICKN)		= gelic_wl_get_nick,
+	IW_HANDLER(SIOCGIWNAME, gelic_wl_get_name),
+	IW_HANDLER(SIOCGIWRANGE, gelic_wl_get_range),
+	IW_HANDLER(SIOCSIWSCAN, gelic_wl_set_scan),
+	IW_HANDLER(SIOCGIWSCAN, gelic_wl_get_scan),
+	IW_HANDLER(SIOCSIWAUTH, gelic_wl_set_auth),
+	IW_HANDLER(SIOCGIWAUTH, gelic_wl_get_auth),
+	IW_HANDLER(SIOCSIWESSID, gelic_wl_set_essid),
+	IW_HANDLER(SIOCGIWESSID, gelic_wl_get_essid),
+	IW_HANDLER(SIOCSIWENCODE, gelic_wl_set_encode),
+	IW_HANDLER(SIOCGIWENCODE, gelic_wl_get_encode),
+	IW_HANDLER(SIOCSIWAP, gelic_wl_set_ap),
+	IW_HANDLER(SIOCGIWAP, gelic_wl_get_ap),
+	IW_HANDLER(SIOCSIWENCODEEXT, gelic_wl_set_encodeext),
+	IW_HANDLER(SIOCGIWENCODEEXT, gelic_wl_get_encodeext),
+	IW_HANDLER(SIOCSIWMODE, gelic_wl_set_mode),
+	IW_HANDLER(SIOCGIWMODE, gelic_wl_get_mode),
+	IW_HANDLER(SIOCGIWNICKN, gelic_wl_get_nick),
 };
 
 static const struct iw_handler_def gelic_wl_wext_handler_def = {
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 5c7aa1b..9e9c532 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -9995,49 +9995,48 @@ static int ipw_wx_sw_reset(struct net_device *dev,
 }
 
 /* Rebase the WE IOCTLs to zero for the handler array */
-#define IW_IOCTL(x) [(x)-SIOCSIWCOMMIT]
 static iw_handler ipw_wx_handlers[] = {
-	IW_IOCTL(SIOCGIWNAME) = (iw_handler) cfg80211_wext_giwname,
-	IW_IOCTL(SIOCSIWFREQ) = ipw_wx_set_freq,
-	IW_IOCTL(SIOCGIWFREQ) = ipw_wx_get_freq,
-	IW_IOCTL(SIOCSIWMODE) = ipw_wx_set_mode,
-	IW_IOCTL(SIOCGIWMODE) = ipw_wx_get_mode,
-	IW_IOCTL(SIOCSIWSENS) = ipw_wx_set_sens,
-	IW_IOCTL(SIOCGIWSENS) = ipw_wx_get_sens,
-	IW_IOCTL(SIOCGIWRANGE) = ipw_wx_get_range,
-	IW_IOCTL(SIOCSIWAP) = ipw_wx_set_wap,
-	IW_IOCTL(SIOCGIWAP) = ipw_wx_get_wap,
-	IW_IOCTL(SIOCSIWSCAN) = ipw_wx_set_scan,
-	IW_IOCTL(SIOCGIWSCAN) = ipw_wx_get_scan,
-	IW_IOCTL(SIOCSIWESSID) = ipw_wx_set_essid,
-	IW_IOCTL(SIOCGIWESSID) = ipw_wx_get_essid,
-	IW_IOCTL(SIOCSIWNICKN) = ipw_wx_set_nick,
-	IW_IOCTL(SIOCGIWNICKN) = ipw_wx_get_nick,
-	IW_IOCTL(SIOCSIWRATE) = ipw_wx_set_rate,
-	IW_IOCTL(SIOCGIWRATE) = ipw_wx_get_rate,
-	IW_IOCTL(SIOCSIWRTS) = ipw_wx_set_rts,
-	IW_IOCTL(SIOCGIWRTS) = ipw_wx_get_rts,
-	IW_IOCTL(SIOCSIWFRAG) = ipw_wx_set_frag,
-	IW_IOCTL(SIOCGIWFRAG) = ipw_wx_get_frag,
-	IW_IOCTL(SIOCSIWTXPOW) = ipw_wx_set_txpow,
-	IW_IOCTL(SIOCGIWTXPOW) = ipw_wx_get_txpow,
-	IW_IOCTL(SIOCSIWRETRY) = ipw_wx_set_retry,
-	IW_IOCTL(SIOCGIWRETRY) = ipw_wx_get_retry,
-	IW_IOCTL(SIOCSIWENCODE) = ipw_wx_set_encode,
-	IW_IOCTL(SIOCGIWENCODE) = ipw_wx_get_encode,
-	IW_IOCTL(SIOCSIWPOWER) = ipw_wx_set_power,
-	IW_IOCTL(SIOCGIWPOWER) = ipw_wx_get_power,
-	IW_IOCTL(SIOCSIWSPY) = iw_handler_set_spy,
-	IW_IOCTL(SIOCGIWSPY) = iw_handler_get_spy,
-	IW_IOCTL(SIOCSIWTHRSPY) = iw_handler_set_thrspy,
-	IW_IOCTL(SIOCGIWTHRSPY) = iw_handler_get_thrspy,
-	IW_IOCTL(SIOCSIWGENIE) = ipw_wx_set_genie,
-	IW_IOCTL(SIOCGIWGENIE) = ipw_wx_get_genie,
-	IW_IOCTL(SIOCSIWMLME) = ipw_wx_set_mlme,
-	IW_IOCTL(SIOCSIWAUTH) = ipw_wx_set_auth,
-	IW_IOCTL(SIOCGIWAUTH) = ipw_wx_get_auth,
-	IW_IOCTL(SIOCSIWENCODEEXT) = ipw_wx_set_encodeext,
-	IW_IOCTL(SIOCGIWENCODEEXT) = ipw_wx_get_encodeext,
+	IW_HANDLER(SIOCGIWNAME, (iw_handler)cfg80211_wext_giwname),
+	IW_HANDLER(SIOCSIWFREQ, ipw_wx_set_freq),
+	IW_HANDLER(SIOCGIWFREQ, ipw_wx_get_freq),
+	IW_HANDLER(SIOCSIWMODE, ipw_wx_set_mode),
+	IW_HANDLER(SIOCGIWMODE, ipw_wx_get_mode),
+	IW_HANDLER(SIOCSIWSENS, ipw_wx_set_sens),
+	IW_HANDLER(SIOCGIWSENS, ipw_wx_get_sens),
+	IW_HANDLER(SIOCGIWRANGE, ipw_wx_get_range),
+	IW_HANDLER(SIOCSIWAP, ipw_wx_set_wap),
+	IW_HANDLER(SIOCGIWAP, ipw_wx_get_wap),
+	IW_HANDLER(SIOCSIWSCAN, ipw_wx_set_scan),
+	IW_HANDLER(SIOCGIWSCAN, ipw_wx_get_scan),
+	IW_HANDLER(SIOCSIWESSID, ipw_wx_set_essid),
+	IW_HANDLER(SIOCGIWESSID, ipw_wx_get_essid),
+	IW_HANDLER(SIOCSIWNICKN, ipw_wx_set_nick),
+	IW_HANDLER(SIOCGIWNICKN, ipw_wx_get_nick),
+	IW_HANDLER(SIOCSIWRATE, ipw_wx_set_rate),
+	IW_HANDLER(SIOCGIWRATE, ipw_wx_get_rate),
+	IW_HANDLER(SIOCSIWRTS, ipw_wx_set_rts),
+	IW_HANDLER(SIOCGIWRTS, ipw_wx_get_rts),
+	IW_HANDLER(SIOCSIWFRAG, ipw_wx_set_frag),
+	IW_HANDLER(SIOCGIWFRAG, ipw_wx_get_frag),
+	IW_HANDLER(SIOCSIWTXPOW, ipw_wx_set_txpow),
+	IW_HANDLER(SIOCGIWTXPOW, ipw_wx_get_txpow),
+	IW_HANDLER(SIOCSIWRETRY, ipw_wx_set_retry),
+	IW_HANDLER(SIOCGIWRETRY, ipw_wx_get_retry),
+	IW_HANDLER(SIOCSIWENCODE, ipw_wx_set_encode),
+	IW_HANDLER(SIOCGIWENCODE, ipw_wx_get_encode),
+	IW_HANDLER(SIOCSIWPOWER, ipw_wx_set_power),
+	IW_HANDLER(SIOCGIWPOWER, ipw_wx_get_power),
+	IW_HANDLER(SIOCSIWSPY, iw_handler_set_spy),
+	IW_HANDLER(SIOCGIWSPY, iw_handler_get_spy),
+	IW_HANDLER(SIOCSIWTHRSPY, iw_handler_set_thrspy),
+	IW_HANDLER(SIOCGIWTHRSPY, iw_handler_get_thrspy),
+	IW_HANDLER(SIOCSIWGENIE, ipw_wx_set_genie),
+	IW_HANDLER(SIOCGIWGENIE, ipw_wx_get_genie),
+	IW_HANDLER(SIOCSIWMLME, ipw_wx_set_mlme),
+	IW_HANDLER(SIOCSIWAUTH, ipw_wx_set_auth),
+	IW_HANDLER(SIOCGIWAUTH, ipw_wx_get_auth),
+	IW_HANDLER(SIOCSIWENCODEEXT, ipw_wx_set_encodeext),
+	IW_HANDLER(SIOCGIWENCODEEXT, ipw_wx_get_encodeext),
 };
 
 enum {
-- 
1.7.0.14.g7e948
