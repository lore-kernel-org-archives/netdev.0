From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] 2.6.17 missing a call to ieee80211softmac_capabilities from
 ieee80211softmac_assoc_req
Date: Tue, 20 Jun 2006 09:19:18 -0500
Message-ID: <449803E6.5020404@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:4794 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1751035AbWFTOTU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 10:19:20 -0400
To: netdev@vger.kernel.org, John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In commit ba9b28d19a3251bb1dfe6a6f8cc89b96fb85f683, routine ieee80211softmac_capabilities was added 
to net/ieee80211/softmac/ieee80211softmac_io.c. As denoted by its name, it completes the 
capabilities IE that is needed in the associate and reassociate requests sent to the AP. For at 
least one AP, the Linksys WRT54G V5, the capabilities field must set the 'short preamble' bit or the 
AP refuses to associate. In the commit noted above, there is a call to the new routine from 
ieee80211softmac_reassoc_req, but not from ieee80211softmac_assoc_req. This patch fixes that oversight.

As noted in the subject, v2.6.17 is affected. My bcm43xx card had been unable to associate since I 
was forced to buy a new AP. I finally was able to get a packet dump and traced the problem to the 
capabilities info. Although I had heard that a patch was "floating around", I had not seen it before 
2.6.17 was released. As this bug does not affect security and I seem to have the only AP affected by 
it, there should be no problem in leaving it for 2.6.18.

Signed-Off-By: Larry Finger <Larry.Finger@lwfinger.net>

index 0954161..8cc8b20 100644
--- a/net/ieee80211/softmac/ieee80211softmac_io.c
+++ b/net/ieee80211/softmac/ieee80211softmac_io.c
@@ -229,6 +229,9 @@ ieee80211softmac_assoc_req(struct ieee8
		return 0;
	ieee80211softmac_hdr_3addr(mac, &((*pkt)->header), IEEE80211_STYPE_ASSOC_REQ, net->bssid, net->bssid);

+	/* Fill in the capabilities */
+	(*pkt)->capability = ieee80211softmac_capabilities(mac, net);
+
	/* Fill in Listen Interval (?) */
	(*pkt)->listen_interval = cpu_to_le16(10);

