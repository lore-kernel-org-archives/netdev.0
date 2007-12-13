From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH 12/12] [DCCP]: Ignore feature negotiation on Data packets
Date: Thu, 13 Dec 2007 13:06:05 -0200
Message-ID: <1197558365-31134-13-git-send-email-acme@redhat.com>
References: <1197558365-31134-1-git-send-email-acme@redhat.com>
 <1197558365-31134-2-git-send-email-acme@redhat.com>
 <1197558365-31134-3-git-send-email-acme@redhat.com>
 <1197558365-31134-4-git-send-email-acme@redhat.com>
 <1197558365-31134-5-git-send-email-acme@redhat.com>
 <1197558365-31134-6-git-send-email-acme@redhat.com>
 <1197558365-31134-7-git-send-email-acme@redhat.com>
 <1197558365-31134-8-git-send-email-acme@redhat.com>
 <1197558365-31134-9-git-send-email-acme@redhat.com>
 <1197558365-31134-10-git-send-email-acme@redhat.com>
 <1197558365-31134-11-git-send-email-acme@redhat.com>
 <1197558365-31134-12-git-send-email-acme@redhat.com>
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Ian McDonald <ian.mcdonald@jandi.co.nz>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.242]:3796 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761931AbXLMPGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 10:06:24 -0500
Received: by an-out-0708.google.com with SMTP id d31so185733and.103
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 07:06:24 -0800 (PST)
In-Reply-To: <1197558365-31134-12-git-send-email-acme@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This implements [RFC 4340, p. 32]: "any feature negotiation options received
on DCCP-Data packets MUST be ignored".

Also added a FIXME for further processing, since the code currently (wrongly)
classifies empty Confirm options as invalid - this needs to be resolved in
a separate patch.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/options.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/dccp/options.c b/net/dccp/options.c
index bedb5da..d2a84a2 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -132,6 +132,8 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 		case DCCPO_CHANGE_L:
 			/* fall through */
 		case DCCPO_CHANGE_R:
+			if (pkt_type == DCCP_PKT_DATA)
+				break;
 			if (len < 2)
 				goto out_invalid_option;
 			rc = dccp_feat_change_recv(sk, opt, *value, value + 1,
@@ -148,7 +150,9 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 		case DCCPO_CONFIRM_L:
 			/* fall through */
 		case DCCPO_CONFIRM_R:
-			if (len < 2)
+			if (pkt_type == DCCP_PKT_DATA)
+				break;
+			if (len < 2)	/* FIXME this disallows empty confirm */
 				goto out_invalid_option;
 			if (dccp_feat_confirm_recv(sk, opt, *value,
 						   value + 1, len - 1))
-- 
1.5.3.4

