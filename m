From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH] ipw2200: add iwconfig rts/frag auto support
Date: Thu, 11 Jan 2007 17:32:54 +0800
Message-ID: <1168507974.10342.530.camel@debian.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:41504 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965323AbXAKJeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jan 2007 04:34:05 -0500
To: "John W.Linville" <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch add ipw2200 support for iwconfig rts/frag auto.

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 ipw2200.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -urp a/drivers/net/wireless/ipw2200.c
b/drivers/net/wireless/ipw2200.c
--- a/drivers/net/wireless/ipw2200.c	2007-01-05 10:53:27.000000000 +0800
+++ b/drivers/net/wireless/ipw2200.c	2007-01-11 17:42:05.000000000 +0800
@@ -9381,7 +9381,7 @@ static int ipw_wx_set_rts(struct net_dev
 {
 	struct ipw_priv *priv = ieee80211_priv(dev);
 	mutex_lock(&priv->mutex);
-	if (wrqu->rts.disabled)
+	if (wrqu->rts.disabled || !wrqu->rts.fixed)
 		priv->rts_threshold = DEFAULT_RTS_THRESHOLD;
 	else {
 		if (wrqu->rts.value < MIN_RTS_THRESHOLD ||
@@ -9470,7 +9470,7 @@ static int ipw_wx_set_frag(struct net_de
 {
 	struct ipw_priv *priv = ieee80211_priv(dev);
 	mutex_lock(&priv->mutex);
-	if (wrqu->frag.disabled)
+	if (wrqu->frag.disabled || !wrqu->frag.fixed)
 		priv->ieee->fts = DEFAULT_FTS;
 	else {
 		if (wrqu->frag.value < MIN_FRAG_THRESHOLD ||
