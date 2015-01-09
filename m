From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next RFC 5/5] net-timestamp: tx timestamping default mode flag
Date: Fri,  9 Jan 2015 12:31:59 -0500
Message-ID: <1420824719-28848-6-git-send-email-willemb@google.com>
References: <1420824719-28848-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, richardcochran@gmail.com,
	eric.dumazet@gmail.com, luto@amacapital.net,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f41.google.com ([209.85.213.41]:33406 "EHLO
	mail-yh0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755706AbbAIRcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 12:32:09 -0500
Received: by mail-yh0-f41.google.com with SMTP id a41so4706314yho.0
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 09:32:09 -0800 (PST)
In-Reply-To: <1420824719-28848-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

The number of timestamping points along the transmit path has grown,
as have the options. Preferred behavior is to request timestamps with
ID, without data (which enables batching) and for all supported
timestamp points. Define a short option that enables all these
defaults.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/uapi/linux/net_tstamp.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/uapi/linux/net_tstamp.h b/include/uapi/linux/net_tstamp.h
index 6d1abea..c371ce2 100644
--- a/include/uapi/linux/net_tstamp.h
+++ b/include/uapi/linux/net_tstamp.h
@@ -27,6 +27,14 @@ enum {
 	SOF_TIMESTAMPING_OPT_TSONLY = (1<<11),
 
 	SOF_TIMESTAMPING_LAST = SOF_TIMESTAMPING_OPT_TSONLY,
+
+	SOF_TIMESTAMPING_TX = SOF_TIMESTAMPING_TX_HARDWARE |
+			      SOF_TIMESTAMPING_TX_SOFTWARE |
+			      SOF_TIMESTAMPING_TX_SCHED |
+			      SOF_TIMESTAMPING_TX_ACK |
+			      SOF_TIMESTAMPING_OPT_ID |
+			      SOF_TIMESTAMPING_OPT_TSONLY,
+
 	SOF_TIMESTAMPING_MASK = (SOF_TIMESTAMPING_LAST - 1) |
 				 SOF_TIMESTAMPING_LAST
 };
-- 
2.2.0.rc0.207.ga3a616c
