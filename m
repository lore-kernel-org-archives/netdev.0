From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH] ipw2100: Fix dropping fragmented small packet problem
Date: Wed, 20 Dec 2006 16:11:58 +0800
Message-ID: <20061220081158.GA28311@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:10469 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964927AbWLTIO4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Dec 2006 03:14:56 -0500
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The rx_data.header struct is ieee80211_hdr_4addr. If a wireless frame uses
ieee80211_hdr_3addr header and is less than 6 bytes, it will be discarded.
This is not likely going to happen for normal packets (since there is TCP, IP
headers). But if fragmentation is used, there will be such small trailing
packets. And they will be lost for ever.

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

diff -urp ipw2100-1.2.1/ipw2100.c ipw2100-1.2.1-frag/ipw2100.c
--- ipw2100-1.2.1/ipw2100.c	2006-02-22 02:46:17.000000000 +0800
+++ ipw2100-1.2.1-frag/ipw2100.c	2006-12-15 17:16:15.000000000 +0800
@@ -2658,7 +2658,7 @@ static void __ipw2100_rx_process(struct 
 				break;
 			}
 #endif
-			if (stats.len < sizeof(u->rx_data.header))
+			if (stats.len < sizeof(struct ieee80211_hdr_3addr))
 				break;
 			switch (WLAN_FC_GET_TYPE(u->rx_data.header.frame_ctl)) {
 			case IEEE80211_FTYPE_MGMT:
