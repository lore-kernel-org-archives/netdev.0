From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 3/3] d80211-p54: Add control structure for beacontemplates
Date: Sat, 3 Feb 2007 17:40:30 +0100
Message-ID: <200702031740.30569.IvDoorn@gmail.com>
References: <200702031725.22885.IvDoorn@gmail.com> <200702031133.52203.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John Linville" <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org
To: Michael Wu <flamingice@sourmilk.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:34278 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946497AbXBCQku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Feb 2007 11:40:50 -0500
Received: by nf-out-0910.google.com with SMTP id o25so1600452nfa
        for <netdev@vger.kernel.org>; Sat, 03 Feb 2007 08:40:48 -0800 (PST)
In-Reply-To: <200702031133.52203.flamingice@sourmilk.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 03 February 2007 17:33, Michael Wu wrote:
> On Saturday 03 February 2007 11:25, Ivo van Doorn wrote:
> > p54 seems to ignore the beacon that is being passed,
> > even though it is requesting the BEACON_TEMPLATE.
> > That is why I not only added a line to free the control structure
> > but also the beacon itself.
> >
> Yeah, beacons aren't actually handled yet. BEACON_TEMPLATE can just be turned 
> off for now if it's causing problems, though I don't see a reason why a 
> beacon would be generated for managed mode.

It would only be generated for AP mode.
In any case, the new patch:

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff --git a/drivers/net/wireless/d80211/p54/prism54common.c b/drivers/net/wireless/d80211/p54/prism54common.c
index fd4ea5d..8335f99 100644
--- a/drivers/net/wireless/d80211/p54/prism54common.c
+++ b/drivers/net/wireless/d80211/p54/prism54common.c
@@ -766,8 +766,7 @@ struct ieee80211_hw *p54_init_common(size_t priv_data_len)
 	priv->modes[0].rates = priv->rates;
 	priv->modes[0].num_channels = ARRAY_SIZE(p54_channels);
 	priv->modes[0].channels = priv->channels;
-	dev->flags = IEEE80211_HW_HOST_GEN_BEACON_TEMPLATE |
-		    IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING | /* not sure */
+	dev->flags = IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING | /* not sure */
 		    IEEE80211_HW_RX_INCLUDES_FCS |
 		    IEEE80211_HW_WEP_INCLUDE_IV |
 		    IEEE80211_HW_DATA_NULLFUNC_ACK; /* TODO: check */
