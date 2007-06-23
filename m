From: Florian Westphal <fw-kernel@strlen.de>
Subject: [PATCH][Resend] TIPC: Fix infinite loop in netlink handler
Date: Sat, 23 Jun 2007 20:25:46 +0200
Message-ID: <20070623182546.GA26081@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:55254 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750804AbXFWSZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 14:25:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

The tipc netlink config handler uses the nlmsg_pid from the
request header as destination for its reply. If the application
initialized nlmsg_pid to 0, the reply is looped back to the kernel,
causing hangup. Fix: use nlmsg_pid of the skb that triggered the
request.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
I already sent this to netdev@ on the 19th, but the patch itself
was neither acked nor Nacked. This is a crash that can be
triggered trivially -- please fix this bug.

 net/tipc/netlink.c |    2 +-
  1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index 4cdafa2..6a7f7b4 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -60,7 +60,7 @@ static int handle_cmd(struct sk_buff *skb, struct genl_info *info)
 		rep_nlh = nlmsg_hdr(rep_buf);
 		memcpy(rep_nlh, req_nlh, hdr_space);
 		rep_nlh->nlmsg_len = rep_buf->len;
-		genlmsg_unicast(rep_buf, req_nlh->nlmsg_pid);
+		genlmsg_unicast(rep_buf, NETLINK_CB(skb).pid);
 	}
 
 	return 0;
