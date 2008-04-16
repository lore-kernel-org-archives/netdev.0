From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Subject: [PATCH] SCTP: Initialize partial_bytes_acked to 0, when all of the
 data is acked.
Date: Wed, 16 Apr 2008 14:55:06 +0800
Message-ID: <4805A2CA.7030808@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	lksctp-dev <lksctp-developers@lists.sourceforge.net>,
	linux-sctp@vger.kernel.org
To: vladislav <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63791 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752329AbYDPG4H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 02:56:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad,
According to RFC4960 7.2.2, 
When all of the data transmitted by the sender has
been acknowledged by the recerver, partial_bytes_acked is initialized to 0.

This patch conforms to rfc requirement. 
Without this fix, cwnd might be error incremented.

Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
---
 net/sctp/outqueue.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index c071446..cf79485 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -1544,6 +1544,9 @@ static void sctp_check_transmitted(struct sctp_outq *q,
 						  bytes_acked);
 
 			transport->flight_size -= bytes_acked;
+			if (transport->flight_size == 0) {
+				transport->partial_bytes_acked = 0;
+			}
 			q->outstanding_bytes -= bytes_acked;
 		} else {
 			/* RFC 2960 6.1, sctpimpguide-06 2.15.2
-- 
1.5.3





