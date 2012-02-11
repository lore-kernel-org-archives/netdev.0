From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Multiple GRE tunnels on the same host, only one routes incoming
 packets
Date: Sat, 11 Feb 2012 12:29:59 +0100
Message-ID: <1328959799.5661.25.camel@edumazet-laptop>
References: <201202111040.q1BAeESi014636@hope.more-right-rudder.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Rick Koshi <netdev@more-right-rudder.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:63290 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754075Ab2BKLaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Feb 2012 06:30:06 -0500
Received: by werb13 with SMTP id b13so2562826wer.19
        for <netdev@vger.kernel.org>; Sat, 11 Feb 2012 03:30:04 -0800 (PST)
In-Reply-To: <201202111040.q1BAeESi014636@hope.more-right-rudder.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 11 f=C3=A9vrier 2012 =C3=A0 05:40 -0500, Rick Koshi a =C3=A9c=
rit :
> I'm having a routing problem on CentOS 6.2 (kernel 2.6.32-220)
>=20
> Here's the setup:  One host is on my local network.  It's talking
> to two nearly identical hosts at a remote location.  The two remote
> hosts are on all the same networks, acting as redundant backups
> for each other.
>=20
> I set up two GRE tunnels from the local host, one to each
> remote host:
>     ip tunnel add name tunnel1 mode gre local 10.2.1.2 remote 10.2.1.=
1
>     ip link set dev tunnel1 up
>     ip route add 172.16.1.0/24 dev tunnel1 metric 101
>=20
>     ip tunnel add name tunnel2 mode gre local 10.2.1.4 remote 10.2.1.=
3
>     ip link set dev tunnel2 up
>     ip route add 172.16.1.0/24 dev tunnel2 metric 102
>=20
> Outgoing packets route properly, no problem.  Incoming packets
> are weird.  It appears that whichever tunnel has the route
> with the higher metric (tunnel2 in the example above) will
> ignore incoming packets.  They come in all right, and can be
> seen on the local machine with 'tcpdump -i tunnel2', but they
> are not routed properly to the local networks.  They're simply
> dropped.  I can switch the two metrics, and then tunnel1 will
> drop all incoming packets.  The tunnel with the lower route
> metric will route packets properly, both incoming and outgoing.
>=20
> Is this "working as designed?"  What I'd like to have happen,
> of course, is for all packets on both tunnels to be properly
> forwarded.  Is this possible?

check :

grep . `find /proc/sys -name rp_filter`
