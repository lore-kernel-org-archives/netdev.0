From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 2/2] ipv6: use sk_v6_copy_addrs when memcpy struct ipv6_pinfo
Date: Tue, 19 Nov 2013 04:14:09 +0100
Message-ID: <20131119031408.GQ16541@order.stressinduktion.org>
References: <1384829247-8624-1-git-send-email-wangweidong1@huawei.com> <1384829247-8624-3-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, gerrit@erg.abdn.ac.uk, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	vyasevich@gmail.com, nhorman@tuxdriver.com, dccp@vger.kernel.org,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	dingtianhong@huawei.com
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51564 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821Ab3KSDOK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 22:14:10 -0500
Content-Disposition: inline
In-Reply-To: <1384829247-8624-3-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 19, 2013 at 10:47:27AM +0800, Wang Weidong wrote:
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 0740f93..83d011e 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -1116,6 +1116,10 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
>  		newtp = tcp_sk(newsk);
>  
>  		memcpy(newnp, np, sizeof(struct ipv6_pinfo));
> +		/* Don't forget copy the rcv_saddr and daddr when
> +		 * copy ipv6_pinfo.
> +		 */
> +		sk_v6_copy_addrs(newsk, sk);
>  
>  		ipv6_addr_set_v4mapped(newinet->inet_daddr, &newsk->sk_v6_daddr);
>  

Hmm, how did you spot this?

Greetings,

  Hannes
