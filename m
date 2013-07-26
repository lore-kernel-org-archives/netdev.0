From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v3] net: split rt_genid for ipv4 and ipv6
Date: Fri, 26 Jul 2013 16:43:16 +0200
Message-ID: <20130726144316.GB3890@order.stressinduktion.org>
References: <1374745632-1624-1-git-send-email-fan.du@windriver.com> <20130725181314.GA24007@order.stressinduktion.org> <51F20DEF.2090108@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: nicolas.dichtel@6wind.com, davem@davemloft.net,
	yoshfuji@linux-ipv6.org, jmorris@namei.org,
	steffen.klassert@secunet.com, netdev <netdev@vger.kernel.org>
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:41300 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759189Ab3GZOnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 10:43:17 -0400
Content-Disposition: inline
In-Reply-To: <51F20DEF.2090108@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 26, 2013 at 01:49:35PM +0800, Fan Du wrote:
> diff --git a/security/selinux/include/xfrm.h 
> b/security/selinux/include/xfrm.h
> index 65f67cb..4f72d2c 100644
> --- a/security/selinux/include/xfrm.h
> +++ b/security/selinux/include/xfrm.h
> @@ -50,8 +50,14 @@ int selinux_xfrm_decode_session(struct sk_buff *skb, u32 
> *sid, int ckall);
> 
>  static inline void selinux_xfrm_notify_policyload(void)
>  {
> +       struct net *net;
> +
>         atomic_inc(&flow_cache_genid);
> -       rt_genid_bump(&init_net);
> +       rtnl_lock();
> +       for_each_net(net) {
> +               rt_genid_bump_all(net);
> +       }
> +       rtnl_unlock();
>  }
>  #else
>  static inline int selinux_xfrm_enabled(void)
> 
> 
> Let me know if I miss something inside it. Thanks.

I do think it is the correct change. The locking seems correct, too. I will
excercise the code with lockdep as soon as you publish a new patch.

Greetings,

  Hannes
