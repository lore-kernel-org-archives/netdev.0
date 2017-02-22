From: Alexey Kodanev <alexey.kodanev@oracle.com>
Subject: [PATCH v2 2/2] tcp: account for ts offset only if tsecr not zero
Date: Wed, 22 Feb 2017 13:23:56 +0300
Message-ID: <1487759036-2800-2-git-send-email-alexey.kodanev@oracle.com>
References: <1487759036-2800-1-git-send-email-alexey.kodanev@oracle.com>
Cc: netdev <netdev@vger.kernel.org>, Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Alexey Kodanev <alexey.kodanev@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:23746 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932177AbdBVKSD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 05:18:03 -0500
In-Reply-To: <1487759036-2800-1-git-send-email-alexey.kodanev@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can get SYN with zero tsecr, don't apply offset in this case.

Fixes: ee684b6f2830 ("tcp: send packets with a socket timestamp")
Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>
---
v2: no changes from the previous version

 net/ipv4/tcp_minisocks.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 28ce5ee..baff824 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -106,7 +106,8 @@ enum tcp_tw_status
 		tcp_parse_options(skb, &tmp_opt, 0, NULL);
 
 		if (tmp_opt.saw_tstamp) {
-			tmp_opt.rcv_tsecr	-= tcptw->tw_ts_offset;
+			if (tmp_opt.rcv_tsecr)
+				tmp_opt.rcv_tsecr -= tcptw->tw_ts_offset;
 			tmp_opt.ts_recent	= tcptw->tw_ts_recent;
 			tmp_opt.ts_recent_stamp	= tcptw->tw_ts_recent_stamp;
 			paws_reject = tcp_paws_reject(&tmp_opt, th->rst);
-- 
1.7.1
