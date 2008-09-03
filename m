From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: net-next-2.6 [pull-request] [PATCH 0/37] dccp: Revised set of
	feature-negotiation patches
Date: Wed, 3 Sep 2008 10:18:39 +0200
Message-ID: <20080903081839.GA9001@gerrit.erg.abdn.ac.uk>
References: <20080901.142055.193705447.davem@davemloft.net> <20080902135055.GB8346@ghostprotocols.net> <20080903042450.GA4105@gerrit.erg.abdn.ac.uk> <20080902.230655.89921076.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@redhat.com, dccp@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:55604 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751219AbYICITA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 04:19:00 -0400
Content-Disposition: inline
In-Reply-To: <20080902.230655.89921076.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| Why don't you put together a tree with just the changes that have
| gone through review and for which you have processed the feedback?
| --
I have a tree for the comments addressed so far. Below is a summary of
the things that have been addressed, when and in which manner.

At the end of the email is an interdiff, relative to the one sent on
Saturday, to reflect the changes that have been newly made to the set.

Urls are
	git://eden-feed.erg.abdn.ac.uk/dccp_exp	[subtree `dccp']
	http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=shortlog;h=dccp

I will respond to Wei's comments after work.

------------------------------------ S u m m a r y ---------------------------

v3 [PATCH 1/1] dccp: Process incoming Change feature-negotiation options
 * fixed concern expressed by Wei to use an empty Confirm instead of a Reset in response to an invalid Change R
 * I am beginning to question whether this is really the right thing to do, may retract this change since it
   requires the host to send an invalid packet type. Anyway it is in the diff below and on
 * http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=63036a38adc389ea49f84dc12f07fbc27be218e5

[PATCH 03/37] dccp: List management for new feature negotiation
 * addressed feedback by Arnaldo, using list_for_each_entry now
 * this was already addressed in the inter-diff from Saturday
 * http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=e6340a7529dd5828a43828f6eb69344eff605902

[PATCH 04/37] dccp: Per-socket initialisation of feature negotiation 
 * not addressed the suggestion to use hlist instead of list_head
 * this may be a possible optimisation for later

[PATCH 06/37] dccp: Limit feature negotiation to connection setup phase
 * responded to comment suggesting to reset connection instead of ignoring anytime feature negotiation
 * to me it seems that the current policy of silently ignoring anytime negotiation is sufficient

[PATCH 07/37] dccp: Registration routines for changing feature values 
 * clarified that registration is based on the registered CCIDs
 * fixed problem identified by Wei: it is permissible to have Confirm lists of partially unknown values,
   the only requirement is that the confirmed value is valid
 * the update actually affects 
   http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=4d4a0a149a2bbdc4381dee02251e9acd6d4967a3	


[PATCH 08/37] dccp: Query supported CCIDs
 * clarified how the registration of new CCIDs is done (http://www.mail-archive.com/dccp@vger.kernel.org/msg02613.html)
 * the main point is that for the moment new CCIDs will remain highly experimental, as a new CCID first requires to
   get an RFC accepted and published by the IETF

[PATCH 09/37] dccp: Resolve dependencies of features on choice of CCID                                                            
 * suggestion by Arnaldo to use struct ccid_operations for the dependencies
 * response in separate thread: this makes the code more complex and should be deferred

[PATCH 12/37] dccp: Feature negotiation for minimum-checksum-coverage 
 * fixed problem pointed out by Arnaldo: changing state only after doing the validity checks
 * already addressed in Saturday's diff
 * http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=952d0535860021c3d5b4b10ca41525c85b3adf69

[PATCH 14/37] dccp: Tidy up setsockopt calls
 * addressed Arnaldo's comment that the switch statement could be simplified
 * addressed Eugene's comment regarding the typecast of optlen
 * already in Saturday's diff
 * http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=ee09a66c65c9eccc181be2aef6ea6af63063869b

[PATCH 15/37] dccp: Set per-connection CCIDs via socket options
 * addressed Arnaldo's comment regarding the maximum option length
 * further generalised it when discussing the maximum length of (Confirm) options
 * in Saturday's diff and below
 * http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=eec7ba87785539c7840baadd0203c0a848fb70f2 

[PATCH 16/37] dccp: API to query the current TX/RX CCID 
 * addressed Arnaldo's comment to simplify ccid_get_current_id into separate ccid_get_current_{rx,tx}_ccid
 * already in Saturday's diff
 * http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=8107a65e721bd36d97fc702796fa490884215b36

[PATCH 19/37] dccp: Header option insertion routine for feature-negotiation
 * responded to Wei's concerns regarding that the length check may be invalid (it is not)
 * http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=e8fa8c43e8741aec75e6a646885d0ab1009776b4


====> Here is the interdiff reflecting yesterday's changes, relative to Saturday <====

		 4 files changed, 10 insertions(+), 12 deletions(-)

--- b/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -1083,13 +1083,10 @@
 
 	/*
 	 *	Negotiation of NN features: Change R is invalid, so there is no
-	 *	simultaneous negotiation; hence we do not consult the list.
+	 *	simultaneous negotiation; hence we do not look up in the list.
 	 */
 	if (type == FEAT_NN) {
-		if (local)
-			goto not_valid_or_not_known;
-
-		if (len > sizeof(fval.nn))
+		if (local || len > sizeof(fval.nn))
 			goto unknown_feature_or_value;
 
 		/* 6.3.2: "The feature remote MUST accept any valid value..." */
@@ -1230,8 +1227,9 @@
 	/*
 	 * Parsing SP Confirms: the first element of @val is the preferred
 	 * SP value which the peer confirms, the remainder depends on @len.
+	 * Note that only the confirmed value need to be a valid SP value.
 	 */
-	if (!dccp_feat_sp_list_ok(feat, val, len))
+	if (!dccp_feat_is_valid_sp_val(feat, val))
 		goto confirmation_failed;
 
 	if (len == 1) {		/* peer didn't supply a preference list */
--- b/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -170,6 +170,8 @@
 	DCCPO_MIN_TX_CCID_SPECIFIC = 192,	/* from receiver to sender */
 	DCCPO_MAX_TX_CCID_SPECIFIC = 255,
 };
+/* maximum size of a single TLV-encoded DCCP option (sans type/len bytes) */
+#define DCCP_SINGLE_OPT_MAXLEN	253
 
 /* DCCP CCIDS */
 enum {
@@ -228,10 +230,6 @@
 #define DCCP_SOCKOPT_CCID_RX_INFO	128
 #define DCCP_SOCKOPT_CCID_TX_INFO	192
 
-/* maximum size of a single TLV-encoded option (sans type/len bytes) */
-#define DCCP_SINGLE_OPT_MAXLEN         253
-/* maximum number of CCID preferences that can be registered at one time */
-#define DCCP_CCID_LIST_MAX_LEN         (DCCP_SINGLE_OPT_MAXLEN - 2)
 /* maximum number of services provided on the same listening port */
 #define DCCP_SERVICE_LIST_MAX_LEN      32
 
--- b/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -15,13 +15,15 @@
 #include "dccp.h"
 
 /*
- * Known limits of feature values.
+ * Known limit values
  */
 /* Ack Ratio takes 2-byte integer values (11.3) */
 #define DCCPF_ACK_RATIO_MAX	0xFFFF
 /* Wmin=32 and Wmax=2^46-1 from 7.5.2 */
 #define DCCPF_SEQ_WMIN		32
 #define DCCPF_SEQ_WMAX		0x3FFFFFFFFFFFull
+/* Maximum number of SP values that fit in a single (Confirm) option */
+#define DCCP_FEAT_MAX_SP_VALS	(DCCP_SINGLE_OPT_MAXLEN - 2)
 
 enum dccp_feat_type {
 	FEAT_AT_RX   = 1,	/* located at RX side of half-connection  */
--- b/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -475,7 +475,7 @@
 	u8 *val;
 	int rc = 0;
 
-	if (optlen < 1 || optlen > DCCP_CCID_LIST_MAX_LEN)
+	if (optlen < 1 || optlen > DCCP_FEAT_MAX_SP_VALS)
 		return -EINVAL;
 
 	val = kmalloc(optlen, GFP_KERNEL);
