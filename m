From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH 2/3] [CCID]: More informative registration
Date: Thu, 13 Dec 2007 23:42:01 -0200
Message-ID: <1197596522-14600-3-git-send-email-acme@redhat.com>
References: <1197596522-14600-1-git-send-email-acme@redhat.com>
 <1197596522-14600-2-git-send-email-acme@redhat.com>
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Ian McDonald <ian.mcdonald@jandi.co.nz>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.245]:30773 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757632AbXLNBmm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 20:42:42 -0500
Received: by an-out-0708.google.com with SMTP id d31so249022and.103
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 17:42:40 -0800 (PST)
In-Reply-To: <1197596522-14600-2-git-send-email-acme@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

The patch makes the registration messages of CCID 2/3 a bit more
informative: instead of repeating the CCID number as currently done,

        "CCID: Registered CCID 2 (ccid2)"  or
        "CCID: Registered CCID 3 (ccid3)",

the descriptive names of the CCID's (from RFCs) are now used:

	"CCID: Registered CCID 2 (TCP-like)" and
	"CCID: Registered CCID 3 (TCP-Friendly Rate Control)".

To allow spaces in the name, the slab name string has been changed to
refer to the numeric CCID identifier, using the same format as before.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccid.c        |    8 ++++----
 net/dccp/ccids/ccid2.c |    2 +-
 net/dccp/ccids/ccid3.c |    2 +-
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/dccp/ccid.c b/net/dccp/ccid.c
index c45088b..4809753 100644
--- a/net/dccp/ccid.c
+++ b/net/dccp/ccid.c
@@ -92,15 +92,15 @@ int ccid_register(struct ccid_operations *ccid_ops)
 
 	ccid_ops->ccid_hc_rx_slab =
 			ccid_kmem_cache_create(ccid_ops->ccid_hc_rx_obj_size,
-					       "%s_hc_rx_sock",
-					       ccid_ops->ccid_name);
+					       "ccid%u_hc_rx_sock",
+					       ccid_ops->ccid_id);
 	if (ccid_ops->ccid_hc_rx_slab == NULL)
 		goto out;
 
 	ccid_ops->ccid_hc_tx_slab =
 			ccid_kmem_cache_create(ccid_ops->ccid_hc_tx_obj_size,
-					       "%s_hc_tx_sock",
-					       ccid_ops->ccid_name);
+					       "ccid%u_hc_tx_sock",
+					       ccid_ops->ccid_id);
 	if (ccid_ops->ccid_hc_tx_slab == NULL)
 		goto out_free_rx_slab;
 
diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 48eeb44..b5b52eb 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -770,7 +770,7 @@ static void ccid2_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 
 static struct ccid_operations ccid2 = {
 	.ccid_id		= DCCPC_CCID2,
-	.ccid_name		= "ccid2",
+	.ccid_name		= "TCP-like",
 	.ccid_owner		= THIS_MODULE,
 	.ccid_hc_tx_obj_size	= sizeof(struct ccid2_hc_tx_sock),
 	.ccid_hc_tx_init	= ccid2_hc_tx_init,
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index a818a1e..876c747 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -943,7 +943,7 @@ static int ccid3_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
 
 static struct ccid_operations ccid3 = {
 	.ccid_id		   = DCCPC_CCID3,
-	.ccid_name		   = "ccid3",
+	.ccid_name		   = "TCP-Friendly Rate Control",
 	.ccid_owner		   = THIS_MODULE,
 	.ccid_hc_tx_obj_size	   = sizeof(struct ccid3_hc_tx_sock),
 	.ccid_hc_tx_init	   = ccid3_hc_tx_init,
-- 
1.5.3.4

