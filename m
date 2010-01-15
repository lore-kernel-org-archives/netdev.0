From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v5] rps: Receive Packet Steering
Date: Fri, 15 Jan 2010 17:20:43 +0800
Message-ID: <412e6f7f1001150120r622450eem2d9f54da27c42fba@mail.gmail.com>
References: <4B5008F5.6090007@gmail.com>
	 <412e6f7f1001142239n704d2827q614f59255e85e328@mail.gmail.com>
	 <4B5011F4.8010204@gmail.com>
	 <20100115.004915.64525965.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, therbert@google.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100115.004915.64525965.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 15, 2010 at 4:49 PM, David Miller <davem@davemloft.net> wro=
te:
>
> Actually, no thanks. =C2=A0Have you actually taken a look at
> ipv6_skip_exthdr()?
>
> Do that, then tell me that you want the extra function call, plus all
> of the processing and data touching that that function does, just to
> handle the case that there "might" be ipv6 extension headers there.
>

I don't think ipv6_skip_exthdr() is too weight. If there isn't any
extra header, only some compare and jump instruments are added, and no
more data references. If there are some headers, I think distributing
packets among CPUs is more important than the extra cost introduced by
calling ipv6_skip_exthdr().

> It is the exception rather than the rule, and I think it's just
> assume we have a real protocol header next.
>
> And that's what skb_tx_hash() used to do too before we started using
> the recorded RX queue and socket hash values.
>
> Nobody cared and nobody complained. =C2=A0Guess why? =C2=A0Because in=
 practice
> it doesn't matter.
>

Maybe they don't know it.If it was a performance regression, I think
more people might pay attention on it.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
