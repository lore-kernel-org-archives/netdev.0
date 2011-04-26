From: Bandan Das <bandan.das@stratus.com>
Subject: Re: [Bugme-new] [Bug 33842] New: NULL pointer dereference in
 ip_fragment
Date: Tue, 26 Apr 2011 16:31:54 -0400
Message-ID: <20110426203154.GM15903@stratus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, tom@dbservice.com,
	Eric Dumazet <eric.dumazet@gmail.com>
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.stratus.com ([134.111.1.18]:35352 "EHLO
	mailhub5.stratus.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753414Ab1DZUc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 16:32:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

https://bugzilla.kernel.org/show_bug.cgi?id=33842

I believe  Eric's recent change to br_parse_ip_options() 
didn't make it to 2.6.39-rc4:

bridge: reset IPCB in br_parse_ip_options
commit f8e9881c2aef1e982e5abc25c046820cd0b7cf64

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 008ff6c..b353f7c 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -249,11 +249,9 @@  static int br_parse_ip_options(struct sk_buff *skb)
           goto drop;
           }
 
-       /* Zero out the CB buffer if no options present */
-       if (iph->ihl == 5) {
-          memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
+          memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
+          if (iph->ihl == 5)
              return 0;
-             }
 
        opt->optlen = iph->ihl*4 - sizeof(struct iphdr);
        if (ip_options_compile(dev_net(dev), opt, skb))



Tomas, could you please try a kernel that has the above 
mentioned change and see if the crash re-occurs ?

Thanks,
Bandan
