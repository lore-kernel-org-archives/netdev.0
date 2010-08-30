From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [RFC][PATCH 1/1] TCP: update initial windows according to RFC 5681
Date: Mon, 30 Aug 2010 07:27:34 +0200
Message-ID: <20100830052734.GB5332@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:59564 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753805Ab0H3F1g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Aug 2010 01:27:36 -0400
Received: from laptev.erg.abdn.ac.uk (Debian-exim@ra-gerrit.erg.abdn.ac.uk [139.133.204.38])
	by erg.abdn.ac.uk (8.13.4/8.13.4) with ESMTP id o7U5RYgf009000
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 30 Aug 2010 06:27:34 +0100 (BST)
Received: from gerrit by laptev.erg.abdn.ac.uk with local (Exim 4.69)
	(envelope-from <gerrit@laptev.erg.abdn.ac.uk>)
	id 1Opwu6-0001UJ-6v
	for netdev@vger.kernel.org; Mon, 30 Aug 2010 07:27:34 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an update to the earlier DCCP 5-patch set, sent separately in case this
question is a contentious issue. 

However, it does look as if the newer RFC 5681 is indeed the normative case for 
the RFC 3390 initial window value. 

If there are no objections, I would like to submit this as an update for net-2.6.

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Patch <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
TCP: use initial window from RFC 5681

This updates the use of larger initial windows, as originally specified in 
RFC 3390, to use the newer IW values specified in RFC 5681, section 3.1.

The changes made in RFC 5681 are:
 a) the setting now is more clearly specified in units of segments (as the
    comments  by John Heffner emphasized, this was not very clear in RFC 3390);
 b) for connections with 1095 < SMSS <= 2190 there is now a change:
    - RFC 3390 says that IW <= 4380,
    - RFC 5681 says that IW = 3 * SMSS <= 6570.

Since RFC 3390 is older and "only" proposed standard, whereas the newer RFC 5681
is already draft standard, it seems preferable to use the newer IW variant.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/net/tcp.h |   10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -791,17 +791,11 @@ static inline __u32 tcp_current_ssthresh
 
 /*
  * Convert RFC 3390 larger initial window into an equivalent number of packets.
- *
- * John Heffner states:
- *
- *	The RFC specifies a window of no more than 4380 bytes
- *	unless 2*MSS > 4380.  Reading the pseudocode in the RFC
- *	is a bit misleading because they use a clamp at 4380 bytes
- *	rather than a multiplier in the relevant range.
+ * This is based on the numbers specified in RFC 5681, 3.1.
  */
 static inline u32 rfc3390_bytes_to_packets(const u32 smss)
 {
-	return smss <= 1095 ? 4 : (smss > 1460 ? 2 : 3);
+	return smss <= 1095 ? 4 : (smss > 2190 ? 2 : 3);
 }
 
 extern void tcp_enter_cwr(struct sock *sk, const int set_ssthresh);

