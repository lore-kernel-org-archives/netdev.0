From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [RFC PATCH net-next 0/7 v2]IPv6:netfilter: defragment
Date: Thu, 25 Mar 2010 17:13:56 +0800
Message-ID: <4BAB2954.9010608@cn.fujitsu.com>
References: <4B88BE30.80206@cn.fujitsu.com> <4B97D34C.4020509@gmail.com> <4B98B4FC.50904@cn.fujitsu.com> <4B9B9766.3090200@linux-ipv6.org> <4B9E5FEC.9010002@trash.net> <4BA8EC4A.9070802@linux-ipv6.org> <4BA8F75E.2040303@trash.net> <4BA90F72.6010404@linux-ipv6.org> <alpine.DEB.2.00.1003232050540.18241@blackhole.kfki.hu> <4BAB2121.2030503@plouf.fr.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Pascal Hambourg <pascal.mail@plouf.fr.eu.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4BAB2121.2030503@plouf.fr.eu.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pascal Hambourg wrote, at 03/25/2010 04:38 PM:
> Hello,
>=20
> Jozsef Kadlecsik a =C3=A9crit :
>> On Wed, 24 Mar 2010, YOSHIFUJI Hideaki wrote:
>>
>>>> In this case without conntrack, IPv6 would send an ICMPv6 message,
>>>> so in my opinion the transparent thing to do would be to still sen=
d
>>>> them. Of course only if reassembly is done on an end host.
>>> Well, no.  conntrack should just forward even uncompleted fragments
>>> to next process (e.g. core ipv6 code), and then the core would send
>>> ICMP error back.  ICMP should be sent by the core ipv6 code accordi=
ng
>>> to decision of itself, not according to netfilter.
>> But what state could be associated by conntrack to the uncompleted=20
>> fragments but the INVALID state? In consequence, in any sane setup, =
the=20
>> uncompleted fragments will be dropped silently by a filter table rul=
e
>> and no ICMP error message will be sent back.
>=20
> AFAIK, in the IPv4 stack the reassembly takes place before the INPUT
> chains (NF_IP_LOCAL_IN hook). Is it different in the IPv6 stack ?

Yes, they are different.

In IPv4 stack=EF=BC=8Cfor an end host, ip_local_deliver() reassemble=20
fragments before LOCAL_IN hook .

But in IPv6 stack, ip6_input_finish() handles fragment extension header=
s
and try to reassemble them *after* LOCAL_IN hook.

--=20
Best Regards
-----
Shan Wei
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
