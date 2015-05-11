From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH 2/2 net-next] net: move qdisc ingress filtering code where
 it belongs
Date: Mon, 11 May 2015 16:02:12 -0700
Message-ID: <555134F4.80007@plumgrid.com>
References: <554FA7A5.5020400@plumgrid.com> <20150510190039.GA4938@salvia>	 <554FAC3A.40701@plumgrid.com> <20150510192044.GA7173@salvia>	 <554FB366.7080509@plumgrid.com> <20150510195018.GA7877@salvia>	 <554FCE24.8020904@iogearbox.net> <554FD12F.2020607@iogearbox.net>	 <20150510234313.GA3176@salvia> <555044D8.3080606@plumgrid.com>	 <20150511133245.GA4430@salvia> <1431354912.566.15.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	davem@davemloft.net, jhs@mojatatu.com
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36811 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837AbbEKXCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 19:02:15 -0400
Received: by pabsx10 with SMTP id sx10so121203665pab.3
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 16:02:15 -0700 (PDT)
In-Reply-To: <1431354912.566.15.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/11/15 7:35 AM, Eric Dumazet wrote:
>
> -static inline int deliver_skb(struct sk_buff *skb,
> +static noinline int deliver_skb(struct sk_buff *skb,
>   			      struct packet_type *pt_prev,
>   			      struct net_device *orig_dev)

have tried the above only and didn't see any difference
for simple 'netif_receive + drop in ip_rcv' test.
Not sure whether it's actually worth doing. I would leave it as-is.
