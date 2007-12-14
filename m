From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH 1/3] [DCCP]: Documentation for CCID operations
Date: Thu, 13 Dec 2007 23:42:00 -0200
Message-ID: <1197596522-14600-2-git-send-email-acme@redhat.com>
References: <1197596522-14600-1-git-send-email-acme@redhat.com>
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Ian McDonald <ian.mcdonald@jandi.co.nz>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.240]:30210 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758153AbXLNBmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 20:42:55 -0500
Received: by an-out-0708.google.com with SMTP id d31so249020and.103
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 17:42:55 -0800 (PST)
In-Reply-To: <1197596522-14600-1-git-send-email-acme@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This adds documentation for the ccid_operations structure.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccid.h |   35 ++++++++++++++++++++++++++++-------
 1 files changed, 28 insertions(+), 7 deletions(-)

diff --git a/net/dccp/ccid.h b/net/dccp/ccid.h
index c65cb24..e3cdd8a 100644
--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -23,14 +23,35 @@
 
 struct tcp_info;
 
+/**
+ *  struct ccid_operations  -  Interface to Congestion-Control Infrastructure
+ *
+ *  @ccid_id: numerical CCID ID (up to %CCID_MAX, cf. table 5 in RFC 4340, 10.)
+ *  @ccid_name: alphabetical identifier string for @ccid_id
+ *  @ccid_owner: module which implements/owns this CCID
+ *  @ccid_hc_{r,t}x_slab: memory pool for the receiver/sender half-connection
+ *  @ccid_hc_{r,t}x_obj_size: size of the receiver/sender half-connection socket
+ *
+ *  @ccid_hc_{r,t}x_init: CCID-specific initialisation routine (before startup)
+ *  @ccid_hc_{r,t}x_exit: CCID-specific cleanup routine (before destruction)
+ *  @ccid_hc_rx_packet_recv: implements the HC-receiver side
+ *  @ccid_hc_{r,t}x_parse_options: parsing routine for CCID/HC-specific options
+ *  @ccid_hc_{r,t}x_insert_options: insert routine for CCID/HC-specific options
+ *  @ccid_hc_tx_packet_recv: implements feedback processing for the HC-sender
+ *  @ccid_hc_tx_send_packet: implements the sending part of the HC-sender
+ *  @ccid_hc_tx_packet_sent: does accounting for packets in flight by HC-sender
+ *  @ccid_hc_{r,t}x_get_info: INET_DIAG information for HC-receiver/sender
+ *  @ccid_hc_{r,t}x_getsockopt: socket options specific to HC-receiver/sender
+ */
 struct ccid_operations {
-	unsigned char	ccid_id;
-	const char	*ccid_name;
-	struct module	*ccid_owner;
-	struct kmem_cache	*ccid_hc_rx_slab;
-	__u32		ccid_hc_rx_obj_size;
-	struct kmem_cache	*ccid_hc_tx_slab;
-	__u32		ccid_hc_tx_obj_size;
+	unsigned char		ccid_id;
+	const char		*ccid_name;
+	struct module		*ccid_owner;
+	struct kmem_cache	*ccid_hc_rx_slab,
+				*ccid_hc_tx_slab;
+	__u32			ccid_hc_rx_obj_size,
+				ccid_hc_tx_obj_size;
+	/* Interface Routines */
 	int		(*ccid_hc_rx_init)(struct ccid *ccid, struct sock *sk);
 	int		(*ccid_hc_tx_init)(struct ccid *ccid, struct sock *sk);
 	void		(*ccid_hc_rx_exit)(struct sock *sk);
-- 
1.5.3.4

