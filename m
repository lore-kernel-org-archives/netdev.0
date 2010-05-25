From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH RFC] netfilter: iptables target SYNPROXY
Date: Tue, 25 May 2010 13:50:52 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1005251347450.8202@obet.zrqbmnf.qr>
References: <1274771218-3204-1-git-send-email-xiaosuo@gmail.com>  <alpine.LSU.2.01.1005251207450.1725@obet.zrqbmnf.qr> <AANLkTim2DrXuBPUBK0TseqVJ5lxPRQjK0P_QJVsbtYRC@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTim2DrXuBPUBK0TseqVJ5lxPRQjK0P_QJVsbtYRC@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tuesday 2010-05-25 13:26, Changli Gao wrote:
>> On Tuesday 2010-05-25 09:06, Changli Gao wrote:
>>> net/ipv4/netfilter/Kconfig =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0| =C2=A0 12
>>> net/ipv4/netfilter/Makefile =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 | =C2=A0 =C2=A01
>>> net/ipv4/netfilter/ipt_SYNPROXY.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 | =C2=A0658 ++++++++++++++++++++++++++++
>>> net/ipv4/syncookies.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 21
>>> net/ipv4/tcp_ipv4.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A05
>>> net/netfilter/nf_conntrack_core.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 | =C2=A0 44 +
>>
>> Please make this an Xtables extension.
>> There is excellent documentation ("Writing Netfilter Modules" to goo=
gle)
>> on the details if needed.
>
>Hmm. I don't know IPv6 well. So I leave it as an iptables extension,
>and hope sb. comes on with IPv6 support after it gets merged.

This should still be xt even if it does not do ipv6.

>>>+ =C2=A0 =C2=A0 =C2=A0th =3D skb_header_pointer(skb, iph->ihl * 4, s=
izeof(_th), &_th);
>>>+ =C2=A0 =C2=A0 =C2=A0BUG_ON(th =3D=3D NULL);
>>
>> I wouldn't call that a bug. I think that can happen on an evil TCP t=
inygram
>> (with proper IPV4 header).
>
>I copied the code from file nf_conntrack_proto_tcp.c. In fact, BUG_ON
>isn't useful at all, as tcp_error is called before this function
>is called.

Ah I see it hard-depends on nf_conntrack_ipv4 (in Kconfig).
That too could be done instead by using nf_ct_get_l3proto at runtime.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
