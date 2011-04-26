From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 33842] New: NULL pointer dereference in
 ip_fragment
Date: Tue, 26 Apr 2011 13:46:37 -0700 (PDT)
Message-ID: <20110426.134637.48491363.davem@davemloft.net>
References: <20110426203154.GM15903@stratus.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	tom@dbservice.com, eric.dumazet@gmail.com
To: bandan.das@stratus.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46216
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756764Ab1DZUrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 16:47:11 -0400
In-Reply-To: <20110426203154.GM15903@stratus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bandan Das <bandan.das@stratus.com>
Date: Tue, 26 Apr 2011 16:31:54 -0400

> https://bugzilla.kernel.org/show_bug.cgi?id=33842
> 
> I believe  Eric's recent change to br_parse_ip_options() 
> didn't make it to 2.6.39-rc4:
> 
> bridge: reset IPCB in br_parse_ip_options
> commit f8e9881c2aef1e982e5abc25c046820cd0b7cf64
> 
> diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
> index 008ff6c..b353f7c 100644
> --- a/net/bridge/br_netfilter.c
> +++ b/net/bridge/br_netfilter.c
> @@ -249,11 +249,9 @@  static int br_parse_ip_options(struct sk_buff *skb)
>            goto drop;
>            }
>  
> -       /* Zero out the CB buffer if no options present */
> -       if (iph->ihl == 5) {
> -          memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
> +          memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
> +          if (iph->ihl == 5)
>               return 0;
> -             }
>  
>         opt->optlen = iph->ihl*4 - sizeof(struct iphdr);
>         if (ip_options_compile(dev_net(dev), opt, skb))
> 
> 
> 
> Tomas, could you please try a kernel that has the above 
> mentioned change and see if the crash re-occurs ?

This patch is mangled by your email client, tab characters
have been turned into spaces, so it won't be usable by anyone.
