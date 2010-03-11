From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [RFC PATCH net-next 0/7 v2]IPv6:netfilter: defragment
Date: Thu, 11 Mar 2010 17:16:44 +0800
Message-ID: <4B98B4FC.50904@cn.fujitsu.com>
References: <4B88BE30.80206@cn.fujitsu.com> <4B97D34C.4020509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org,
	"yoshfuji@linux-ipv6.org >> YOSHIFUJI Hideaki"
	<yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B97D34C.4020509@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

yoshifuji-san:

YOSHIFUJI Hideaki wrote, at 03/11/2010 01:13 AM:
> Well, because the context of defragment are different
> from standard ones (e.g., In netfilter, defragment can
> happen even on forwarding path, and the result is always
> thrown away anyway), I think it is not a good idea to
> touch standard MIB here. However I'm okay to increment
> other stats like InDiscards, OurDiscards and netfilter
> specific stats.

Not only on router, but also on host, if conntrack fails to reassemble
fragments, the fragments will not be forwarded to IPv4/IPv6 stack.
So, these fragments can't be traced from MIB counter.

And, IPv4 conntrack records these fragments.
Is the context of IPv4 defragment different from IPv6?

> On the other hand, I'd even say we should NOT send
> icmp here (at least by default) because standard routers
> never send such packet.

Yes=EF=BC=8Cfor routers, the patch-set does not send icmp message to
source host. It only does on destination host with IPv6 connection=20
track enable.

--=20
Best Regards
-----
Shan Wei
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
