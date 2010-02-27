From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [RFC PATCH net-next 0/7 v2]IPv6:netfilter: defragment
Date: Sat, 27 Feb 2010 14:39:44 +0800
Message-ID: <4B88BE30.80206@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 This patch-set solves the problem that an end host with IPv6 connectio=
n track enable
can't send an ICMP "Fragment Reassembly Timeout" message when defaging =
timeout.
And supports MIB counter about fragments reassembly e.g. Ip6ReasmTimeou=
t, Ip6ReasmReqds,
Ip6ReasmOKs, Ip6ReasmFails.

patch-1,2,3=EF=BC=9A Introduce net namespace to conntrack and share net=
ns_frags with IPv6 stack. =20
          But, IPv6 conntrack and IPv6 stack still keep separate fragme=
nt queue.
          Like IPv4, proc parameters of ip6frag_low_thresh, ip6frag_tim=
e and ip6frag_high_thresh
          manage numbers and memory thresh size of both IPv6 conntrack =
fragment queue and=20
          IPv6 stack fragment queue.

patch-4: Send an ICMP "Fragment Reassembly Timeout" message and record =
MIB counter=20
         when defraging timeout.

patch-5,6,7: According to RFC4293, record MIB counter about fragments r=
eassembly.


This patch-set has been tested using IPv6 Ready Logo Phase-2 tool under=
 host and router type.

---
Shan Wei <shanwei@cn.fujitsu.com> (7):
      IPv6:netfilter: defrag: Handle sysctls about IPv6 conntrack defra=
gment per-netns
      IPv6:netfilter: defrag: Introduce per-netns to conntrack and kill=
 nf_init_frags
      IPv6:netfilter: defrag: Disable button half when reassembling a f=
ragment=20
      IPv6:netfilter: Send an ICMPv6 "Fragment Reassembly Timeout" mess=
age when enabling connection track
      IPv6:netfilter: Record MIB counter when reassembling all fragment=
s
      IPv6:netfilter: Record MIB counter after a fragment reached
      IPv6:netfilter: Add IPSTATS_MIB_REASMFAILS MIB counter value when=
 evicting fragment queue

 Documentation/feature-removal-schedule.txt     |   19 ++
 include/linux/skbuff.h                         |    5 +
 include/net/netns/ipv6.h                       |    1 +
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    7 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c        |  221 ++++++++++++++++=
+++-----
 net/ipv6/route.c                               |    1 +
 6 files changed, 208 insertions(+), 46 deletions(-)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
