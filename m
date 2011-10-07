From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Asserting ECN from userspace?
Date: Fri, 07 Oct 2011 07:23:09 +0200
Message-ID: <1317964989.3457.39.camel@edumazet-laptop>
References: <4E8BF6B2.6030101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bloat-devel@lists.bufferbloat.net
To: David =?ISO-8859-1?Q?T=E4ht?= <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63837 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755973Ab1JGFXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 01:23:18 -0400
Received: by wwf22 with SMTP id 22so5327071wwf.1
        for <netdev@vger.kernel.org>; Thu, 06 Oct 2011 22:23:16 -0700 (PDT)
In-Reply-To: <4E8BF6B2.6030101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 04 octobre 2011 =C3=A0 23:18 -0700, David T=C3=A4ht a =C3=A9cr=
it :
> No sooner had I noted (with pleasure) the kernel's new ability to
> correctly set the dscp bits on IPv6 TCP streams without messing with =
the
> negotiated ECN status, that I found several use cases where being abl=
e
> to assert ECN from userspace (for either ipv4, or ipv6) would be usef=
ul.
>=20
> 1) Applications such as bittorrent (transmission, etc) that are much
> more aware of their overall environment could assert ECN on their UDP
> streams to indicate congestion.
>=20
> 2) Test tools. It would be nice to be able, from userspace, to easily
> diagnose if ECN was working on a stream, end to end, and being able t=
o
> set and receive the ECN bits on a less algorithmic basis (ie, not wed=
ged
> deep within a kernel aqm such as RED or SFB)
>=20
> 3) Web Proxies. A web proxy could note when it was experiencing
> congestion on one side of the proxied connection (or another) and sig=
nal
> the other side to slow down.
>=20
> Ah, ECN, we hardly know ye.
>=20
> as for item 1 I'm hard pressed to think of a case where setting the E=
CN
> bits on udp streams would introduce a security problem.
>=20
> As for 2, can live without.
>=20
> As for 3... perhaps a grantable network capability? A proxy could
> acquire privs to twiddle those bits before dropping root privs.
>=20
> That begs the question of how to see those bits in the first place. O=
OB
> data?
>=20
> And twiddling them, on a per stream basis, for a single packet, would
> seem to require something more robust than setsockopt/getsockopt
> (although that would work for udp streams)
>=20

=46or UDP, its really easy to set ECT(0) or ECT(1) in your outgoing
frames, and test as well ECT(0),ECT(1),ECN in incoming frames.

=46or the sending part:
int tos =3D 0x2; /* ECT(1) */
setsockopt(fd, IP_PROTOIP, IP_TOS, &tos, sizeof(tos));

To be able to get the TOS value :

int on =3D 1;
setsockopt(fd, IP_PROTOIP, IP_RECVTOS, &on, sizeof(on));

RECVTOS (since Linux 2.2)
     If  enabled the IP_TOS ancillary message is passed with incoming p=
ackets.
     It contains a byte which specifies the Type of Service/Precedence
     field of the packet header.  Expects a boolean integer flag.
