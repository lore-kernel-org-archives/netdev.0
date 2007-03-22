From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH] [SCTP] Correctly reset ssthresh when restarting association
Date: Thu, 22 Mar 2007 14:56:19 -0400
Message-ID: <4602D153.4000201@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	"lksctp-developers@lists.sourceforge.net"
	<lksctp-developers@lists.sourceforge.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:43510 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934193AbXCVS41 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 14:56:27 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reset ssthresh to the correct value (peer's a_rwnd) when restarting
association.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/transport.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index c4699f5..4d8c2ab 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -538,7 +538,7 @@ void sctp_transport_reset(struct sctp_transport *t)
 	 * (see Section 6.2.1)
 	 */
 	t->cwnd = min(4*asoc->pathmtu, max_t(__u32, 2*asoc->pathmtu, 4380));
-	t->ssthresh = SCTP_DEFAULT_MAXWINDOW;
+	t->ssthresh = asoc->peer.i.a_rwnd;
 	t->rto = asoc->rto_initial;
 	t->rtt = 0;
 	t->srtt = 0;
-- 
1.5.0.3.438.gc49b2

