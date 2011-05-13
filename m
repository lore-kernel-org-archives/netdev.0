From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] bridge: fix forwarding of IPv6
Date: Fri, 13 May 2011 12:53:14 -0700
Message-ID: <20110513125314.66861b31@nehalam>
References: <20110506201234.6297.70279.reportbug@ip6-localhost>
 <1304995124.4065.157.camel@localhost>
 <20110510043833.GG6397@morgul.net>
 <1305031369.4065.259.camel@localhost>
 <20110510180540.GI6397@morgul.net>
 <20110510151100.52a9f8fa@nehalam>
 <20110510233540.GJ6397@morgul.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <ben@decadent.org.uk>,
	bridge@lists.linux-foundation.org, netdev <netdev@vger.kernel.org>
To: Noah Meyerhans <noahm@debian.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56744 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757113Ab1EMTxR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2011 15:53:17 -0400
In-Reply-To: <20110510233540.GJ6397@morgul.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 6b1e960fdbd75dcd9bcc3ba5ff8898ff1ad30b6e
    bridge: Reset IPCB when entering IP stack on NF_FORWARD
broke forwarding of IPV6 packets in bridge because it would
call bp_parse_ip_options with an IPV6 packet.

Reported-by: Noah Meyerhans <noahm@debian.org>
Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Patch against net-next-2.6 but must be applied to net-2.6
and stable as well

--- a/net/bridge/br_netfilter.c	2011-05-13 12:37:30.289646958 -0700
+++ b/net/bridge/br_netfilter.c	2011-05-13 12:38:07.820333938 -0700
@@ -737,7 +737,7 @@ static unsigned int br_nf_forward_ip(uns
 		nf_bridge->mask |= BRNF_PKT_TYPE;
 	}
 
-	if (br_parse_ip_options(skb))
+	if (pf == PF_INET && br_parse_ip_options(skb))
 		return NF_DROP;
 
 	/* The physdev module checks on this */


-- 
