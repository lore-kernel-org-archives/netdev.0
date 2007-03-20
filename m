From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: [PATCH 18/31] [CCID3]: Fix use of invalid loss intervals
Date: Tue, 20 Mar 2007 20:15:17 -0300
Message-ID: <20070320231517.GG17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.225]:39497 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752206AbXCTXPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 19:15:22 -0400
Received: by wx-out-0506.google.com with SMTP id h31so66936wxd
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 16:15:21 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes a bug which uses an invalid comparison.
The bug resulted in the use of invalid loss intervals.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/lib/loss_interval.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index 0a0baef..372d7e7 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -91,7 +91,7 @@ u32 dccp_li_hist_calc_i_mean(struct list_head *list)
 	u32 w_tot  = 0;
 
 	list_for_each_entry_safe(li_entry, li_next, list, dccplih_node) {
-		if (li_entry->dccplih_interval != ~0) {
+		if (li_entry->dccplih_interval != ~0U) {
 			i_tot0 += li_entry->dccplih_interval * dccp_li_hist_w[i];
 			w_tot  += dccp_li_hist_w[i];
 			if (i != 0)
-- 
1.5.0.3

