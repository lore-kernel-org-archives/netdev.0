From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] ipv6: Kill ipv6 dependency of icmpv6_send().
Date: Thu, 25 Apr 2013 12:08:44 -0700
Message-ID: <1366916924.8964.177.camel@edumazet-glaptop>
References: <1366915075-1538-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:38916 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759100Ab3DYTIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 15:08:46 -0400
Received: by mail-pd0-f173.google.com with SMTP id v14so654571pde.32
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 12:08:46 -0700 (PDT)
In-Reply-To: <1366915075-1538-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-25 at 11:37 -0700, Pravin B Shelar wrote:

> +int inet6_register_icmp_sender(ip6_icmp_send_t *fn)
> +{
> +	return (cmpxchg(&ip6_icmp_send, NULL, fn) == NULL) ? 0 : -EBUSY;
> +}
> +EXPORT_SYMBOL(inet6_register_icmp_sender);
> +
> +int inet6_unregister_icmp_sender(ip6_icmp_send_t *fn)
> +{
> +	int ret;
> +
> +	ret = (cmpxchg(&ip6_icmp_send, fn, NULL) == fn) ? 0 : -EINVAL;
> +
> +	synchronize_net();
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL(inet6_unregister_icmp_sender);

Good idea, but I bet you didn't run sparse on this code...

CONFIG_SPARSE_RCU_POINTER=y

make C=2 net/ipv6/ip6_icmp.o

you probably need to cast to (ip6_icmp_send_t *)
