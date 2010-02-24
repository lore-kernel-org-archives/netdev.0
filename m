From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [RFC PATCH net-next 0/5]IPv6:netfilter: defragment
Date: Wed, 24 Feb 2010 14:07:14 +0800
Message-ID: <4B84C212.5070900@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch-set solves the problem that an end host with IPv6 connection=
 track enable
can't send an ICMP "Fragment Reassembly Timeout" message when defaging =
timeout.
And supports MIB counter about fragments reassembly e.g. Ip6ReasmTimeou=
t, Ip6ReasmReqds,
Ip6ReasmOKs, Ip6ReasmFails.

patch-1=EF=BC=9A Introduce net namespace to conntrack and share netns_f=
rags with IPv6 stack. =20
          But, IPv6 conntrack and IPv6 stack still keep separate fragme=
nt queue.
          Like IPv4, proc parameters of ip6frag_low_thresh, ip6frag_tim=
e and ip6frag_high_thresh
          manage numbers and memory thresh size of both IPv6 conntrack =
fragment queue and=20
          IPv6 stack fragment queue.

patch-2: Send an ICMP "Fragment Reassembly Timeout" message and record =
MIB counter=20
         when defraging timeout.

patch-3,4,5: According to RFC4293, record MIB counter about fragments r=
eassembly.


This patch-set has been tested using IPv6 Ready Logo Phase-2 tool under=
 host and router type.

---
Shan Wei <shanwei@cn.fujitsu.com> (5):
      IPv6:netfilter: defrag:Introduce net namespace to conntrack and s=
hare netns_frags with IPv6 stack
      IPv6:netfilter: Send an ICMPv6 "Fragment Reassembly Timeout" mess=
age when enabling connection track
      IPv6:netfilter: Record MIB counter when reassembling all fragment=
s
      IPv6:netfilter: Record MIB counter after a fragment reached
      IPv6:netfilter: Add IPSTATS_MIB_REASMFAILS MIB counter value when=
 evicting fragment queue

 include/linux/skbuff.h                         |    5 +
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    7 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c        |  165 +++++++++++++++-=
--------
 net/ipv6/route.c                               |    1 +
 4 files changed, 110 insertions(+), 68 deletions(-)

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
