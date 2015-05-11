From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2 net-next] net: move qdisc ingress filtering code
 where it belongs
Date: Mon, 11 May 2015 16:30:38 -0700
Message-ID: <1431387038.566.47.camel@edumazet-glaptop2.roam.corp.google.com>
References: <554FA7A5.5020400@plumgrid.com> <20150510190039.GA4938@salvia>
	 <554FAC3A.40701@plumgrid.com> <20150510192044.GA7173@salvia>
	 <554FB366.7080509@plumgrid.com> <20150510195018.GA7877@salvia>
	 <554FCE24.8020904@iogearbox.net> <554FD12F.2020607@iogearbox.net>
	 <20150510234313.GA3176@salvia> <555044D8.3080606@plumgrid.com>
	 <20150511133245.GA4430@salvia>
	 <1431354912.566.15.camel@edumazet-glaptop2.roam.corp.google.com>
	 <555134F4.80007@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	davem@davemloft.net, jhs@mojatatu.com
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:34097 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837AbbEKXak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 19:30:40 -0400
Received: by iedfl3 with SMTP id fl3so137008666ied.1
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 16:30:39 -0700 (PDT)
In-Reply-To: <555134F4.80007@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-05-11 at 16:02 -0700, Alexei Starovoitov wrote:
> On 5/11/15 7:35 AM, Eric Dumazet wrote:
> >
> > -static inline int deliver_skb(struct sk_buff *skb,
> > +static noinline int deliver_skb(struct sk_buff *skb,
> >   			      struct packet_type *pt_prev,
> >   			      struct net_device *orig_dev)
> 
> have tried the above only and didn't see any difference
> for simple 'netif_receive + drop in ip_rcv' test.
> Not sure whether it's actually worth doing. I would leave it as-is.

Yes, this was probably too aggressive.

unlikely() or static_key_false() are no moving code away enough, whole
function including unused code pollutes icache.

Code size increased a lot, while L1/L2 caches on cpu are about the same
than 6 years ago.

For example , commit 7866a621043fbaca3d7389e9b9f69dd1a2e5a855
helped a given workload, but probably made things slower for most common
cases.
