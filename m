From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: avoid expensive pskb_expand_head() calls
Date: Wed, 18 Apr 2012 21:18:27 +0200
Message-ID: <1334776707.2472.316.camel@edumazet-glaptop>
References: <1334653608.6226.11.camel@edumazet-laptop>
	 <1334654187.2696.2.camel@jtkirshe-mobl> <4F8D93E1.9090000@intel.com>
	 <1334681204.2472.41.camel@edumazet-glaptop>
	 <1334698722.2472.71.camel@edumazet-glaptop>
	 <1334764184.2472.299.camel@edumazet-glaptop>
	 <CADVnQy=BkhSBHyN2hyBy=_H64oM8sJvyZZfEjK1x7PYzoLv=5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:57942 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754665Ab2DRTSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 15:18:36 -0400
Received: by bkcik5 with SMTP id ik5so5775553bkc.19
        for <netdev@vger.kernel.org>; Wed, 18 Apr 2012 12:18:35 -0700 (PDT)
In-Reply-To: <CADVnQy=BkhSBHyN2hyBy=_H64oM8sJvyZZfEjK1x7PYzoLv=5w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-04-18 at 14:40 -0400, Neal Cardwell wrote:

> 
> > +       prev_packets_acked = tcp_skb_pcount(skb);
> 
> FWIW, I'd find old_pcount or prev_pcount a little easier to read than
> prev_packets_acked here (I see "oldpcount" is used in tcp_output
> in a similar context).
> 

You're right, I'll change this.

> >        TCP_SKB_CB(skb)->seq += len;
> > +       TCP_SKB_CB(skb)->header.offset_ack = 0;
> 
> If the caller decides to trim a prefix of the skb that does not extend
> to snd_una, then setting offset_ack to 0 here will cause us to forget
> that some prefix is ACKed when we should have remembered this.
> However, the API for the function invites the caller to chop off an
> arbitrary amount (and there's no comment to disuade the caller from
> trying this). This seems to risk bugs in the future.
> 
> To attempt to make this API safer and simpler for future generations,
> what do you think about calculating the len inside tcp_trim_head(),
> something like:
> 
> static int tcp_trim_head(struct sock *sk, struct sk_buff *skb)
> {
>   u32 len = tp->snd_una - TCP_SKB_CB(skb)->seq;
> ...
> 
> ...
>  if (tcp_trim_head(sk, skb))
> ...
> 

Very good point, I'll use this suggestion too in v2.

Thanks !
