From: Manavalan Krishnan <manavalan_k@yahoo.com>
Subject: Re: Large file copy to NFS mounted directory causes delay in other application packets
Date: Wed, 9 Nov 2011 00:13:09 -0800 (PST)
Message-ID: <1320826389.47194.YahooMailNeo@web160716.mail.bf1.yahoo.com>
References: <1320816503.73813.YahooMailNeo@web160718.mail.bf1.yahoo.com> <1320819875.26025.48.camel@edumazet-laptop>
Reply-To: Manavalan Krishnan <manavalan_k@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm22.bullet.mail.bf1.yahoo.com ([98.139.212.181]:22131 "HELO
	nm22.bullet.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755551Ab1KIINL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Nov 2011 03:13:11 -0500
In-Reply-To: <1320819875.26025.48.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(1) NFS is using TCP
(2) yes eth0 is dedicated to heartbeat and eth1 is dedicated to NFS
(3) I notice the following at the system where file copy is occuring

The kernel Recv-Q of the heartbeat application socket grows but not del=
ivered to the socket recv call.=A0
Here is the netstat output.

Proto=A0 Recv-Q=A0 Send-Q=A0=A0 Local Address=A0=A0=A0=A0=A0=A0=A0=A0 F=
oreign Address

udp=A0=A0=A0 11522=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0=A0 *:=
23435=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 *:*

As soon as I stop the file transfer, the socket recv call receives the =
packets and Recv-Q goes 0.
(4) The server has 4 cpu cores and 25G RAM

________________________________
=46rom: Eric Dumazet <eric.dumazet@gmail.com>
To: Manavalan Krishnan <manavalan_k@yahoo.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>; netd=
ev <netdev@vger.kernel.org>
Sent: Tuesday, November 8, 2011 10:24 PM
Subject: Re: Large file copy to NFS mounted directory causes delay in o=
ther application packets

Le mardi 08 novembre 2011 =E0 21:28 -0800, Manavalan Krishnan a =E9crit=
 :
> Hi All
>=20
> I have two systems with two network interfaces each(eth0 and eth1). I
> am running linux-HA (heartbeat deamon) on both the systems and they
> use eth0 for exchanging heartbeats. I have NFS mounted directory in
> one system and the NFS client uses the interface eth1.=20
>=20
> I try to copy a large file to NFS mounted directory. But the heartbea=
t
> daemons misses the heartbeat packets from peers while copy is under
> progress. I did tcpdump and found that the heartbeat packets are
> delayed for few seconds before sent out on eth0. When I stop the file
> copy, the heartbeats are delivered properly. It seems linux kernel
> somehow giving priority for NFS packets(generated from the file copy)
> over other application packets.
>=20
> Any thoughts on this behavior? Is there any way we can avoid this so
> that application packets get equal chance while large file copy to NF=
S
> mounted directory under progress?
>=20
CC netdev

1) Is your NFS using UDP or TCP ?
2) Is your eth0 dedicated to heartbeats and eth1 to NFS traffic ?
3) How do you know heartbeats are delayed ?
4) Is your server CPU bounded ?

Thanks


--
To unsubscribe from this list: send the line "unsubscribe linux-kernel"=
 in
the body of a message to majordomo@vger.kernel.org
More majordomo info at=A0 http://vger.kernel.org/majordomo-info.html
Please read the FAQ at=A0 http://www.tux.org/lkml/
