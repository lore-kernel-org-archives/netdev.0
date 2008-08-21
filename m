From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 2/3] dccp: Fill in the Data fields when option processing encounters option errors
Date: Thu, 21 Aug 2008 19:19:47 +0200
Message-ID: <1219339188-31873-3-git-send-email-gerrit@erg.abdn.ac.uk>
References: <test_tree_updates_for_parsing_header_options>
 <1219339188-31873-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219339188-31873-2-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: netdev@vger.kernel.org, Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:36303 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753965AbYHURUA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Aug 2008 13:20:00 -0400
In-Reply-To: <1219339188-31873-2-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This updates the use of the `out_invalid_option' label, which produces a
Reset (code 5, "Option Error"), to fill in the  Data1...Data3 fields as
specified in RFC 4340, 5.6.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/options.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -291,6 +291,9 @@ out_invalid_option:
 	DCCP_INC_STATS_BH(DCCP_MIB_INVALIDOPT);
 	DCCP_SKB_CB(skb)->dccpd_reset_code = DCCP_RESET_CODE_OPTION_ERROR;
 	DCCP_WARN("DCCP(%p): invalid option %d, len=%d", sk, opt, len);
+	DCCP_SKB_CB(skb)->dccpd_reset_data[0] = opt;
+	DCCP_SKB_CB(skb)->dccpd_reset_data[1] = len > 0 ? value[0] : 0;
+	DCCP_SKB_CB(skb)->dccpd_reset_data[2] = len > 1 ? value[1] : 0;
 	return -1;
 }
 
