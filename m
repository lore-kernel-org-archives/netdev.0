From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v5] rps: Receive Packet Steering
Date: Fri, 15 Jan 2010 14:39:13 +0800
Message-ID: <412e6f7f1001142239n704d2827q614f59255e85e328@mail.gmail.com>
References: <alpine.DEB.1.00.1001141353140.19018@pokey.mtv.corp.google.com>
	 <412e6f7f1001141822pffa070ap15c73e2931402294@mail.gmail.com>
	 <4B5008F5.6090007@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B5008F5.6090007@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 15, 2010 at 2:19 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le 15/01/2010 03:22, Changli Gao a =C3=A9crit :
>> On Fri, Jan 15, 2010 at 5:56 AM, Tom Herbert <therbert@google.com> w=
rote:
>>> +
>>> + =C2=A0 =C2=A0 =C2=A0 if (skb->rxhash)
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto got_hash; /=
* Skip hash computation on packet header */
>>> +
>>> + =C2=A0 =C2=A0 =C2=A0 switch (skb->protocol) {
>>> + =C2=A0 =C2=A0 =C2=A0 case __constant_htons(ETH_P_IP):
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!pskb_may_pu=
ll(skb, sizeof(*ip)))
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 goto done;
>>> +
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ip =3D (struct i=
phdr *) skb->data;
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ip_proto =3D ip-=
>protocol;
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 addr1 =3D ip->sa=
ddr;
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 addr2 =3D ip->da=
ddr;
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ihl =3D ip->ihl;
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>>> + =C2=A0 =C2=A0 =C2=A0 case __constant_htons(ETH_P_IPV6):
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!pskb_may_pu=
ll(skb, sizeof(*ip6)))
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 goto done;
>>> +
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ip6 =3D (struct =
ipv6hdr *) skb->data;
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ip_proto =3D ip6=
->nexthdr;
>> This code can't work, when there are extra headers. ipv6_skip_exthdr=
()
>> can be used to get the l4 header.
>
> Could you give exact code please ?
>

The code bellow is from my ifb-mq.patch
#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
        case __constant_htons(ETH_P_IPV6):
process_ipv6:
                if (unlikely(!pskb_may_pull(skb, sizeof(struct ipv6hdr)=
)))
                        goto process_other;
                addr1 =3D ipv6_hdr(skb)->saddr.s6_addr32[3];
                addr2 =3D ipv6_hdr(skb)->daddr.s6_addr32[3];
                ihl =3D ipv6_skip_exthdr(skb, sizeof(struct ipv6hdr), &=
ip_proto);
                if (unlikely(ihl < 0))
                        goto process_other_trans;
                break;
#endif


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
