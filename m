From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] rps: Receive Packet Steering
Date: Fri, 15 Jan 2010 00:49:15 -0800 (PST)
Message-ID: <20100115.004915.64525965.davem@davemloft.net>
References: <4B5008F5.6090007@gmail.com>
	<412e6f7f1001142239n704d2827q614f59255e85e328@mail.gmail.com>
	<4B5011F4.8010204@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, therbert@google.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B5011F4.8010204@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 15 Jan 2010 07:57:56 +0100

> Le 15/01/2010 07:39, Changli Gao a =E9crit :
>> The code bellow is from my ifb-mq.patch
>> #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
>>         case __constant_htons(ETH_P_IPV6):
>> process_ipv6:
>>                 if (unlikely(!pskb_may_pull(skb, sizeof(struct ipv6h=
dr))))
>>                         goto process_other;
>>                 addr1 =3D ipv6_hdr(skb)->saddr.s6_addr32[3];
>>                 addr2 =3D ipv6_hdr(skb)->daddr.s6_addr32[3];
>>                 ihl =3D ipv6_skip_exthdr(skb, sizeof(struct ipv6hdr)=
, &ip_proto);
>>                 if (unlikely(ihl < 0))
>>                         goto process_other_trans;
>>                 break;
>> #endif
>>=20
>>=20
>=20
> Thanks Changli !

Actually, no thanks.  Have you actually taken a look at
ipv6_skip_exthdr()?

Do that, then tell me that you want the extra function call, plus all
of the processing and data touching that that function does, just to
handle the case that there "might" be ipv6 extension headers there.

It is the exception rather than the rule, and I think it's just
assume we have a real protocol header next.

And that's what skb_tx_hash() used to do too before we started using
the recorded RX queue and socket hash values.

Nobody cared and nobody complained.  Guess why?  Because in practice
it doesn't matter.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
