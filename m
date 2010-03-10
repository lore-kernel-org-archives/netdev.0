From: YOSHIFUJI Hideaki <hideaki.yoshifuji@gmail.com>
Subject: Re: [RFC PATCH net-next 0/7 v2]IPv6:netfilter: defragment
Date: Thu, 11 Mar 2010 02:13:48 +0900
Message-ID: <4B97D34C.4020509@gmail.com>
References: <4B88BE30.80206@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org,
	"yoshfuji@linux-ipv6.org >> YOSHIFUJI Hideaki"
	<yoshfuji@linux-ipv6.org>
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B88BE30.80206@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Shan Wei wrote:
>  This patch-set solves the problem that an end host with IPv6 connect=
ion track enable
> can't send an ICMP "Fragment Reassembly Timeout" message when defagin=
g timeout.
> And supports MIB counter about fragments reassembly e.g. Ip6ReasmTime=
out, Ip6ReasmReqds,
> Ip6ReasmOKs, Ip6ReasmFails.

Well, because the context of defragment are different
from standard ones (e.g., In netfilter, defragment can
happen even on forwarding path, and the result is always
thrown away anyway), I think it is not a good idea to
touch standard MIB here. However I'm okay to increment
other stats like InDiscards, OurDiscards and netfilter
specific stats.
On the other hand, I'd even say we should NOT send
icmp here (at least by default) because standard routers
never send such packet.

Regards,

--yoshfuji

> patch-1,2,3=EF=BC=9A Introduce net namespace to conntrack and share n=
etns_frags with IPv6 stack. =20
>           But, IPv6 conntrack and IPv6 stack still keep separate frag=
ment queue.
>           Like IPv4, proc parameters of ip6frag_low_thresh, ip6frag_t=
ime and ip6frag_high_thresh
>           manage numbers and memory thresh size of both IPv6 conntrac=
k fragment queue and=20
>           IPv6 stack fragment queue.
>=20
> patch-4: Send an ICMP "Fragment Reassembly Timeout" message and recor=
d MIB counter=20
>          when defraging timeout.
>=20
> patch-5,6,7: According to RFC4293, record MIB counter about fragments=
 reassembly.
>=20
>=20
> This patch-set has been tested using IPv6 Ready Logo Phase-2 tool und=
er host and router type.
>=20
> ---
> Shan Wei <shanwei@cn.fujitsu.com> (7):
>       IPv6:netfilter: defrag: Handle sysctls about IPv6 conntrack def=
ragment per-netns
>       IPv6:netfilter: defrag: Introduce per-netns to conntrack and ki=
ll nf_init_frags
>       IPv6:netfilter: defrag: Disable button half when reassembling a=
 fragment=20
>       IPv6:netfilter: Send an ICMPv6 "Fragment Reassembly Timeout" me=
ssage when enabling connection track
>       IPv6:netfilter: Record MIB counter when reassembling all fragme=
nts
>       IPv6:netfilter: Record MIB counter after a fragment reached
>       IPv6:netfilter: Add IPSTATS_MIB_REASMFAILS MIB counter value wh=
en evicting fragment queue
>=20
>  Documentation/feature-removal-schedule.txt     |   19 ++
>  include/linux/skbuff.h                         |    5 +
>  include/net/netns/ipv6.h                       |    1 +
>  net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    7 +-
>  net/ipv6/netfilter/nf_conntrack_reasm.c        |  221 ++++++++++++++=
+++++-----
>  net/ipv6/route.c                               |    1 +
>  6 files changed, 208 insertions(+), 46 deletions(-)
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
