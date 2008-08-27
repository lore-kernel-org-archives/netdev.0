From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 3/6] dccp: Fill in the Data fields for "Option Error" Resets
Date: Wed, 27 Aug 2008 07:35:22 +0200
Message-ID: <1219815325-13778-4-git-send-email-gerrit@erg.abdn.ac.uk>
References: <20080827050636.GB6760@gerrit.erg.abdn.ac.uk>
 <1219815325-13778-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219815325-13778-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219815325-13778-3-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:46925 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751614AbYH0Ffe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 01:35:34 -0400
In-Reply-To: <1219815325-13778-3-git-send-email-gerrit@erg.abdn.ac.uk>
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
 
