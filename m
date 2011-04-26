From: Bandan Das <bandan.das@stratus.com>
Subject: Re: [Bugme-new] [Bug 33842] New: NULL pointer dereference in
 ip_fragment
Date: Tue, 26 Apr 2011 17:19:46 -0400
Message-ID: <20110426211946.GO15903@stratus.com>
References: <20110426203154.GM15903@stratus.com>
 <20110426.134637.48491363.davem@davemloft.net>
 <1303851185.2699.7.camel@edumazet-laptop>
 <20110426205901.GN15903@stratus.com>
 <1303851718.2699.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bandan Das <bandan.das@stratus.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, tom@dbservice.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.stratus.com ([134.111.1.18]:35671 "EHLO
	mailhub5.stratus.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932287Ab1DZVUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 17:20:38 -0400
Content-Disposition: inline
In-Reply-To: <1303851718.2699.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Umm.. I could be wrong! I just did a quick grep for your name in the 
> > 2.6.39-rc4 changelog : 
> > http://www.kernel.org/pub/linux/kernel/v2.6/testing/ChangeLog-2.6.39-rc4
> > 
> > and didn't find it there.
> 
> Then it will be in rc5, dont worry ;)
> 
> 
Yeah, I just rechecked and this is already in Linus' tree. So, Tomas you can
either try pulling in those changes or you can apply this patch and see
if it makes any difference. Thanks!


diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 008ff6c..f3bc322 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -249,11 +249,9 @@ static int br_parse_ip_options(struct sk_buff *skb)
 		goto drop;
 	}
 
-	/* Zero out the CB buffer if no options present */
-	if (iph->ihl == 5) {
-		memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
+	memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
+	if (iph->ihl == 5)
 		return 0;
-	}
 
 	opt->optlen = iph->ihl*4 - sizeof(struct iphdr);
 	if (ip_options_compile(dev_net(dev), opt, skb))
