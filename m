From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: [PATCH net-next 04/14] ipv6: added net argument to
	IP6_INC_STATS_BH
Date: Wed, 08 Oct 2008 23:07:25 +0400
Message-ID: <1223492845.6664.0.camel@iris.sw.ru>
References: <1223466685.7184.13.camel@iris.sw.ru>
	 <1223466722-8169-4-git-send-email-den@openvz.org>
	 <20081008.111309.227060133.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dlezcano@fr.ibm.com,
	benjamin.thery@bull.net, xemul@openvz.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:30787 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752045AbYJHTJk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 15:09:40 -0400
In-Reply-To: <20081008.111309.227060133.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-10-08 at 11:13 -0700, David Miller wrote:
> From: "Denis V. Lunev" <den@openvz.org>
> Date: Wed,  8 Oct 2008 15:51:52 +0400
> 
> > Signed-off-by: Denis V. Lunev <den@openvz.org>
> 
> Please type "make allmodconfig" before all test builds.
> Or at least use grep when changing interface signatures.
> 
> You missed net/ipv6/ip6mr.c in these changes.
> 
> I added the following change to your commit to fix the
> build:
> 
> diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
> index 095bc45..182f8a1 100644
> --- a/net/ipv6/ip6mr.c
> +++ b/net/ipv6/ip6mr.c
> @@ -1383,7 +1383,8 @@ int ip6mr_ioctl(struct sock *sk, int cmd, void __user *arg)
>  
>  static inline int ip6mr_forward2_finish(struct sk_buff *skb)
>  {
> -	IP6_INC_STATS_BH(ip6_dst_idev(skb->dst), IPSTATS_MIB_OUTFORWDATAGRAMS);
> +	IP6_INC_STATS_BH(dev_net(skb->dst->dev), ip6_dst_idev(skb->dst),
> +			 IPSTATS_MIB_OUTFORWDATAGRAMS);
>  	return dst_output(skb);
>  }
>  

sorry. thanks a lot


