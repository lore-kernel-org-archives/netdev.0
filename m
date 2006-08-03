From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH] d80211: fix wrong logical operations
Date: Thu, 3 Aug 2006 13:59:45 +0200
Message-ID: <20060803135945.2b076abe@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:30371 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932362AbWHCL7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 07:59:47 -0400
Received: from griffin.suse.cz (griffin.suse.cz [10.20.1.99])
	by mail.suse.cz (SUSE CR ESMTP Mailer) with ESMTP id ACB4D628067
	for <netdev@vger.kernel.org>; Thu,  3 Aug 2006 13:59:45 +0200 (CEST)
To: NetDev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Several comparisons were always evaluated to false due to incorrect logical
operations.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_ioctl.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

--- dscape.orig/net/d80211/ieee80211_ioctl.c
+++ dscape/net/d80211/ieee80211_ioctl.c
@@ -2500,7 +2500,7 @@ static int ieee80211_ioctl_prism2_param(
 		break;
 
 	case PRISM2_PARAM_MIXED_CELL:
-		if (sdata->type != IEEE80211_IF_TYPE_STA ||
+		if (sdata->type != IEEE80211_IF_TYPE_STA &&
 		    sdata->type != IEEE80211_IF_TYPE_IBSS)
 			ret = -EINVAL;
 		else
@@ -2525,7 +2525,7 @@ static int ieee80211_ioctl_prism2_param(
 			sdata->u.sta.create_ibss = !!value;
 		break;
 	case PRISM2_PARAM_WMM_ENABLED:
-		if (sdata->type != IEEE80211_IF_TYPE_STA ||
+		if (sdata->type != IEEE80211_IF_TYPE_STA &&
 		    sdata->type != IEEE80211_IF_TYPE_IBSS)
 			ret = -EINVAL;
 		else
@@ -2712,7 +2712,7 @@ static int ieee80211_ioctl_get_prism2_pa
 		break;
 
 	case PRISM2_PARAM_MIXED_CELL:
-		if (sdata->type != IEEE80211_IF_TYPE_STA ||
+		if (sdata->type != IEEE80211_IF_TYPE_STA &&
 		    sdata->type != IEEE80211_IF_TYPE_IBSS)
 			ret = -EINVAL;
 		else
@@ -2726,7 +2726,7 @@ static int ieee80211_ioctl_get_prism2_pa
 			*param = sdata->u.sta.key_mgmt;
 		break;
 	case PRISM2_PARAM_WMM_ENABLED:
-		if (sdata->type != IEEE80211_IF_TYPE_STA ||
+		if (sdata->type != IEEE80211_IF_TYPE_STA &&
 		    sdata->type != IEEE80211_IF_TYPE_IBSS)
 			ret = -EINVAL;
 		else
@@ -2778,7 +2778,7 @@ static int ieee80211_ioctl_siwmlme(struc
 	struct iw_mlme *mlme = (struct iw_mlme *) extra;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->type != IEEE80211_IF_TYPE_STA ||
+	if (sdata->type != IEEE80211_IF_TYPE_STA &&
 	    sdata->type != IEEE80211_IF_TYPE_IBSS)
 		return -EINVAL;
 

-- 
Jiri Benc
SUSE Labs
