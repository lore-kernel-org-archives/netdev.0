From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Fix ip_skb_dst_mtu to use the sk passed by
 ip_finish_output
Date: Thu, 30 Jun 2016 09:03:15 -0400 (EDT)
Message-ID: <20160630.090315.592285556929128713.davem@davemloft.net>
References: <1467226023-4168-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@redhat.com, tom@herbertland.com, azhou@ovn.org,
	stephen@networkplumber.org, netdev@vger.kernel.org
To: shmulik.ladkani@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55837 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751424AbcF3NLF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 09:11:05 -0400
In-Reply-To: <1467226023-4168-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Date: Wed, 29 Jun 2016 21:47:03 +0300

> ip_skb_dst_mtu uses skb->sk, assuming it is an AF_INET socket (e.g. it
> calls ip_sk_use_pmtu which casts sk as an inet_sk).
> 
> However, in the case of UDP tunneling, the skb->sk is not necessarily an
> inet socket (could be AF_PACKET socket, or AF_UNSPEC if arriving from
> tun/tap).
> 
> OTOH, the sk passed as an argument throughout IP stack's output path is
> the one which is of PMTU interest:
>  - In case of local sockets, sk is same as skb->sk;
>  - In case of a udp tunnel, sk is the tunneling socket.
> 
> Fix, by passing ip_finish_output's sk to ip_skb_dst_mtu.
> This augments 7026b1ddb6 'netfilter: Pass socket pointer down through okfn().'
> 
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Applied, thanks.
