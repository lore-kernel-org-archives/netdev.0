From: =?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@ynet.sk>
Subject: Re: [patch v4, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Wed, 25 Jan 2012 08:38:15 +0100
Message-ID: <CAGsizzJqNgos89pp-0ivw6ZmUd3+SehwdAnPY7FuGG+xvPWxAg@mail.gmail.com>
References: <20120123.134352.1621146585245670953.davem@davemloft.net>
 <CAGsizzJnQ6b6eSC0ZnAtFguU7_xDfWFPSY6L4DWXc24F+Ts2XQ@mail.gmail.com>
 <CAOzFzEjE7b-Y+_vOWeBKbHDkURRcYXomSTcwB91vKHVWQxBVsg@mail.gmail.com>
 <20120124.230203.1478271172075708903.davem@davemloft.net> <CAEP_g=9H9dV9=qtFPh4YeTNQ-t+UZGw-YqZ6hFWVNXjFy+GCZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	joseph.glanville@orionvm.com.au, eric.dumazet@gmail.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEP_g=9H9dV9=qtFPh4YeTNQ-t+UZGw-YqZ6hFWVNXjFy+GCZg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/1/25 Jesse Gross <jesse@nicira.com>:
> On Tue, Jan 24, 2012 at 8:02 PM, David Miller <davem@davemloft.net> w=
rote:
>> From: Joseph Glanville <joseph.glanville@orionvm.com.au>
>> Date: Wed, 25 Jan 2012 14:48:37 +1100
>>
>>> The reason why this patch is useful is that it stands to be the onl=
y
>>> true mulitpoint L2 VPN with a kernel space forwarding plane.
>>
>> So what you're telling me is that I added this huge openvswitch
>> thing essentially for nothing?
>
> I think it's actually the opposite - Open vSwitch can be used to
> implement this type of thing as well as for many other use cases. =A0=
On
> the other hand, even when implementing a multipoint L2 solution it ca=
n
> be useful to have additional levels of control but you can't do that
> with this patch because it essentially statically glues together
> tunneling and bridging.
Yes, those methods are glued together. If you are speaking about
additional level of controls. What kind of control is missing?

As if I compare it to standard bridge, it is missing:
-  STP code, which is not relevant here as the topology inside the
gretap bridge never reaches loops - it represent more one shared link
than box with multiple links from STP point of view. On the other hand
STP can be tunneled inside of that tunnel by putting gretap interface
as part of some bridge e.g. "brctl addif br0 gretap0".
- IGMP/MLD snooping. IGMP/MLD snooping are useful features, but due
the encapsulation rules, the only one optimalization can be done and
that's if in ONLY ONE gretap enabled nodes requires to join some
multicast group inside the gretap and one node has source behind. In
that case those frames can be forwarded to only that gretap node. In
case of two or more, the encapsulation process will result in using
multicast as underlying technology so any one of the gretap nodes will
received the frames regardless of state if IGMP/MLD. On the other hand
such multicast optimalizations are missing from whole GRE tunnels code
(PIM/MLD/IGMP snooping, using something like cisco Multicast Domain
Trees/MDT....), so if somebody wants to optimize that feel free, but
don't blame this patch for missing those.
- did I miss something?
