From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] ieee80211softmac: fix verbosity when debug disabled
Date: Sat, 04 Nov 2006 13:29:50 -0600
Message-ID: <454CEA2E.mail3QE112KF3@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms-smtp-03.rdc-kc.rr.com ([24.94.166.129]:24786 "EHLO
	ms-smtp-03.rdc-kc.rr.com") by vger.kernel.org with ESMTP
	id S1753680AbWKDTaq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Nov 2006 14:30:46 -0500
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SoftMAC contains a number of debug-type messages that continue to print
even when debugging is turned off. This patch substitutes dprintkl for
printkl for those lines.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---


Index: wireless-2.6/net/ieee80211/softmac/ieee80211softmac_auth.c
===================================================================
--- wireless-2.6.orig/net/ieee80211/softmac/ieee80211softmac_auth.c
+++ wireless-2.6/net/ieee80211/softmac/ieee80211softmac_auth.c
@@ -158,7 +158,7 @@ ieee80211softmac_auth_resp(struct net_de
 	/* Make sure that we've got an auth queue item for this request */
 	if(aq == NULL)
 	{
-		printkl(KERN_DEBUG PFX "Authentication response received from "MAC_FMT" but no queue item exists.\n", MAC_ARG(auth->header.addr2));
+		dprintkl(KERN_DEBUG PFX "Authentication response received from "MAC_FMT" but no queue item exists.\n", MAC_ARG(auth->header.addr2));
 		/* Error #? */
 		return -1;
 	}			
@@ -166,7 +166,7 @@ ieee80211softmac_auth_resp(struct net_de
 	/* Check for out of order authentication */
 	if(!net->authenticating)
 	{
-		printkl(KERN_DEBUG PFX "Authentication response received from "MAC_FMT" but did not request authentication.\n",MAC_ARG(auth->header.addr2));
+		dprintkl(KERN_DEBUG PFX "Authentication response received from "MAC_FMT" but did not request authentication.\n",MAC_ARG(auth->header.addr2));
 		return -1;
 	}
 
@@ -342,7 +342,7 @@ ieee80211softmac_deauth_req(struct ieee8
 	/* Make sure the network is authenticated */
 	if (!net->authenticated)
 	{
-		printkl(KERN_DEBUG PFX "Can't send deauthentication packet, network is not authenticated.\n");
+		dprintkl(KERN_DEBUG PFX "Can't send deauthentication packet, network is not authenticated.\n");
 		/* Error okay? */
 		return -EPERM;
 	}
@@ -376,7 +376,7 @@ ieee80211softmac_deauth_resp(struct net_
 	net = ieee80211softmac_get_network_by_bssid(mac, deauth->header.addr2);
 	
 	if (net == NULL) {
-		printkl(KERN_DEBUG PFX "Received deauthentication packet from "MAC_FMT", but that network is unknown.\n",
+		dprintkl(KERN_DEBUG PFX "Received deauthentication packet from "MAC_FMT", but that network is unknown.\n",
 			MAC_ARG(deauth->header.addr2));
 		return 0;
 	}
@@ -384,7 +384,7 @@ ieee80211softmac_deauth_resp(struct net_
 	/* Make sure the network is authenticated */
 	if(!net->authenticated)
 	{
-		printkl(KERN_DEBUG PFX "Can't perform deauthentication, network is not authenticated.\n");
+		dprintkl(KERN_DEBUG PFX "Can't perform deauthentication, network is not authenticated.\n");
 		/* Error okay? */
 		return -EPERM;
 	}
