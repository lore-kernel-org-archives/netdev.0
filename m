From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: How is IPv6 dhcp supposed to work?
Date: Wed, 18 Jun 2014 12:37:37 +0200
Message-ID: <87ha3isdu6.fsf@nemi.mork.no>
References: <53A0B617.6070600@candelatech.com>
	<1403044471.16272.20.camel@dcbw.local>
	<53A0CC31.6090707@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Williams <dcbw@redhat.com>, netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:52315 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966142AbaFRKiA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 06:38:00 -0400
In-Reply-To: <53A0CC31.6090707@candelatech.com> (Ben Greear's message of "Tue,
	17 Jun 2014 16:16:01 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear <greearb@candelatech.com> writes:

> Does that router advert below look proper?=20

No, it doesn't.  How did you create this?

> I'm going printk diving in
> the IPv6 stack in the meantime...
>
>
> [root@simech2-f17x64 lanforge]# cat pkt.txt
> No.     Time        Source                Destination           Proto=
col Length Info
>      34 229.636063  fe80::e4be:86ff:fe27:a33 ff02::1               IC=
MPv6   110    Router Advertisement from e6:be:86:27:0a:33
>
> Frame 34: 110 bytes on wire (880 bits), 110 bytes captured (880 bits)
> Ethernet II, Src: e6:be:86:27:0a:33 (e6:be:86:27:0a:33), Dst: IPv6mca=
st_00:00:00:01 (33:33:00:00:00:01)
> Internet Protocol Version 6, Src: fe80::e4be:86ff:fe27:a33 (fe80::e4b=
e:86ff:fe27:a33), Dst: ff02::1 (ff02::1)
> Internet Control Message Protocol v6
>     Type: Router Advertisement (134)
>     Code: 0
>     Checksum: 0x6088 [correct]
>     Cur hop limit: 64
>     Flags: 0x00
>     Router lifetime (s): 300
>     Reachable time (ms): 0
>     Retrans timer (ms): 0
>     ICMPv6 Option (Prefix information : 2001:78::1/64)
>         Type: Prefix information (3)
>         Length: 4 (32 bytes)
>         Prefix Length: 64
>         Flag: 0xe0
>         Valid Lifetime: 86400
>         Preferred Lifetime: 14400
>         Reserved
>         Prefix: 2001:78::1 (2001:78::1)

Quoting RFC 4861 (http://tools.ietf.org/html/rfc4861#section-4.6.2 ):

      Prefix         An IP address or a prefix of an IP address.  The
                     Prefix Length field contains the number of valid
                     leading bits in the prefix.  The bits in the prefi=
x
                     after the prefix length are reserved and MUST be
                     initialized to zero by the sender and ignored by
                     the receiver.=20


So that prefix should have been '2001:78::'

Note that you don't necessarily need to include a prefix option in the
RA.  If you don't want clients on the link connected to the router to
communicate directly on L2.  This is the typical ISP use case.


Bj=C3=B8rn
