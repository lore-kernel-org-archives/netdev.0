From: Gerrit Renker <acme@ghostprotocols.net>
Subject: [PATCH 13/31] [DCCP]: Fix for follows48
Date: Tue, 20 Mar 2007 20:13:35 -0300
Message-ID: <20070320231335.GB17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:38396 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752126AbXCTXNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 19:13:40 -0400
Received: by wx-out-0506.google.com with SMTP id h31so66486wxd
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 16:13:40 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The follows48 relation identifies whether 48-bit sequence number
x is the direct successor of y. Currently, it does not handle cases
of the following type correctly:

	follows48(0x(prefix)10000LL, 0x(prefix)0FFFFLL)

where prefix is an arbitrary hex sequence of up to 7 digits.

This is fixed by reusing the new dccp_delta_seqno function.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/dccp.h |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 287a040..2c5be61 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -144,9 +144,7 @@ static inline u64 max48(const u64 seq1, const u64 seq2)
 /* is seq1 next seqno after seq2 */
 static inline int follows48(const u64 seq1, const u64 seq2)
 {
-	int diff = (seq1 & 0xFFFF) - (seq2 & 0xFFFF);
-
-	return diff==1;
+	return dccp_delta_seqno(seq2, seq1) == 1;
 }
 
 enum {
-- 
1.5.0.3

