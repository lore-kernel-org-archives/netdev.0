From: Dan Williams <dcbw@redhat.com>
Subject: Re: How is IPv6 dhcp supposed to work?
Date: Wed, 18 Jun 2014 08:43:10 -0500
Message-ID: <1403098990.2266.13.camel@dcbw.local>
References: <53A0B617.6070600@candelatech.com>
	 <1403044471.16272.20.camel@dcbw.local> <53A0CC31.6090707@candelatech.com>
	 <87ha3isdu6.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2209 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966707AbaFRNnS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2014 09:43:18 -0400
In-Reply-To: <87ha3isdu6.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-06-18 at 12:37 +0200, Bj=C3=B8rn Mork wrote:
> Ben Greear <greearb@candelatech.com> writes:
>=20
> > Does that router advert below look proper?=20
>=20
> No, it doesn't.  How did you create this?
>=20
> > I'm going printk diving in
> > the IPv6 stack in the meantime...
> >
> >
> > [root@simech2-f17x64 lanforge]# cat pkt.txt
> > No.     Time        Source                Destination           Pro=
tocol Length Info
> >      34 229.636063  fe80::e4be:86ff:fe27:a33 ff02::1               =
ICMPv6   110    Router Advertisement from e6:be:86:27:0a:33
> >
> > Frame 34: 110 bytes on wire (880 bits), 110 bytes captured (880 bit=
s)
> > Ethernet II, Src: e6:be:86:27:0a:33 (e6:be:86:27:0a:33), Dst: IPv6m=
cast_00:00:00:01 (33:33:00:00:00:01)
> > Internet Protocol Version 6, Src: fe80::e4be:86ff:fe27:a33 (fe80::e=
4be:86ff:fe27:a33), Dst: ff02::1 (ff02::1)
> > Internet Control Message Protocol v6
> >     Type: Router Advertisement (134)
> >     Code: 0
> >     Checksum: 0x6088 [correct]
> >     Cur hop limit: 64
> >     Flags: 0x00
> >     Router lifetime (s): 300
> >     Reachable time (ms): 0
> >     Retrans timer (ms): 0
> >     ICMPv6 Option (Prefix information : 2001:78::1/64)
> >         Type: Prefix information (3)
> >         Length: 4 (32 bytes)
> >         Prefix Length: 64
> >         Flag: 0xe0
> >         Valid Lifetime: 86400
> >         Preferred Lifetime: 14400
> >         Reserved
> >         Prefix: 2001:78::1 (2001:78::1)
>=20
> Quoting RFC 4861 (http://tools.ietf.org/html/rfc4861#section-4.6.2 ):
>=20
>       Prefix         An IP address or a prefix of an IP address.  The
>                      Prefix Length field contains the number of valid
>                      leading bits in the prefix.  The bits in the pre=
fix
>                      after the prefix length are reserved and MUST be
>                      initialized to zero by the sender and ignored by
>                      the receiver.=20
>=20
>=20
> So that prefix should have been '2001:78::'

This is actually a problem in the wild, and radvd doesn't prevent this
being configured (thanks radvd!!!).  So client implementations do need
to mask off any host bits in the received prefix, no matter what the RF=
C
says :(

Dan
