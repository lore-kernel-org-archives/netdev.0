From: Jan Stancek <jstancek@redhat.com>
Subject: Re: bridge is not forwaring ICMP6 neighbor solicitation to KVM
 guest
Date: Tue, 4 Mar 2014 06:06:29 -0500 (EST)
Message-ID: <1663332249.12962360.1393931189285.JavaMail.zimbra@redhat.com>
References: <1566805413.12693479.1393872931017.JavaMail.zimbra@redhat.com> <2107636851.12713862.1393876035292.JavaMail.zimbra@redhat.com> <20140303212759.GW5090@Linus-Debian> <1808019554.12748658.1393886749190.JavaMail.zimbra@redhat.com> <20140304000041.GY5090@Linus-Debian> <624414844.12834668.1393920156458.JavaMail.zimbra@redhat.com> <20140304105253.GC5090@Linus-Debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Florian Westphal <fwestpha@redhat.com>,
	bridge@lists.linux-foundation.org
To: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@web.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:48906 "EHLO
	mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756239AbaCDLGa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 06:06:30 -0500
In-Reply-To: <20140304105253.GC5090@Linus-Debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
> From: "Linus L=C3=BCssing" <linus.luessing@web.de>
> To: "Jan Stancek" <jstancek@redhat.com>
> Cc: netdev@vger.kernel.org, "Florian Westphal" <fwestpha@redhat.com>,=
 bridge@lists.linux-foundation.org
> Sent: Tuesday, 4 March, 2014 11:52:54 AM
> Subject: Re: bridge is not forwaring ICMP6 neighbor solicitation to K=
VM guest
>=20
> Hi Jan,
>=20
> On Tue, Mar 04, 2014 at 03:02:36AM -0500, Jan Stancek wrote:
> > > For the broken query, ok, it's your manually crafted query. But
> > > did you see a query with such a bogus source address "in the
> > > wild", too? (I'm curious how urgent this sanity check is)
> >=20
> > It's real packet I managed to capture during one such occurrence.
> > I'm sending it with small C program over raw socket, but it's byte
> > by byte exact copy of what I captured with tcpdump previously.
> >=20
> > I'm not sure how that packet came to existence. Based on IPv6 addre=
ss
> > it came from host B, but all host B was doing at the time
> > was running RHEL6 with couple qemu-kvm instances. KVM guests were
> > set up to use bridge, so I'm assuming if any of them crafted
> > this packet, source IPv6 address would be different.
> >=20
>=20
> Ah, okay. Can you check whether it maybe came from the querier
> code in the Linux bridge on host B? Is
> "cat /sys/class/net/br0/bridge/multicast_querier" 1?

# cat /sys/class/net/br0/bridge/multicast_querier
cat: /sys/class/net/br0/bridge/multicast_querier: No such file or direc=
tory

> Can you isolate host B and disable any multicast router daemon on it?=
 Then
> check again, if you still see these queries.

Besides those cases where I sent it by myself, I haven't seen host B se=
nd
that query for couple days now.

> What kernel version is running on host B?

2.6.32-279.42.1.el6.x86_64
It's a RHEL6.3.z kernel.

> Where does Linux use :: for queries?

I'm not sure if it's Linux (I'm trying to locate that system by MAC), b=
ut I see
packets like these on my network every ~125 seconds:

No.     Time        Source                Destination           Protoco=
l Length Info
  22675 1334.751135 ::                    ff02::1               ICMPv6 =
  86     Multicast Listener Query

Internet Control Message Protocol v6
    Type: Multicast Listener Query (130)
    Code: 0
    Checksum: 0x7ac1 [correct]
    Maximum Response Delay [ms]: 1000
    Reserved: 0000
    Multicast Address: :: (::)

Regards,
Jan
