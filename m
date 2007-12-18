From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: After many hours all outbound connections get stuck in SYN_SENT
Date: Tue, 18 Dec 2007 21:37:32 +0100
Message-ID: <47682F8C.20205@cosmosbay.com>
References: <83a51e120712141239u52d2dd68p1b6ee7ed08f2cecf@mail.gmail.com>	 <Pine.LNX.4.64.0712180009390.32270@fbirervta.pbzchgretzou.qr>	 <83a51e120712180734i334399dbl51f44fe32d815f7d@mail.gmail.com>	 <Pine.LNX.4.64.0712181704380.4422@fbirervta.pbzchgretzou.qr>	 <83a51e120712180845k6cadf67bn5dd66fb2d3ac72d4@mail.gmail.com>	 <Pine.LNX.4.64.0712181818360.4422@fbirervta.pbzchgretzou.qr>	 <83a51e120712181009pf954f43mcb63ea4dab638458@mail.gmail.com>	 <Pine.LNX.4.64.0712181910580.4422@fbirervta.pbzchgretzou.qr>	 <83a51e120712181021p4c4c2a13g8820271f1e00361b@mail.gmail.com>	 <4768123A.7040603@cosmosbay.com> <83a51e120712181144l65633b32r72cc369f9d012f47@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Engelhardt <jengelh@computergmbh.de>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: James Nichols <jamesnichols3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:34250 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521AbXLRUhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2007 15:37:43 -0500
In-Reply-To: <83a51e120712181144l65633b32r72cc369f9d012f47@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

James Nichols a =E9crit :
>> Well... please dont start a flame war :(
>>
>> Back to your SYN_SENT problem, I suppose the remote IP is known, so =
you
>> probably could post here the result of a tcdpump ?
>>
>> tcpdump -p -n -s 1600 host IP_of_problematic_peer -c 500
>>
>> Most probably remote peer received too many attempts from you, and a
>> anti DOS mechanism is droping all SYN packets.
>>
>> Ah well... I remember now that you mentioned tcp_sack setting had an
>> effect, so forget the "Most probably..." and give some tcpdump trace=
s :)
>=20
>=20
> I've run tcpdump for all IPs during this problem.  I haven't tried
> doing it for a single explicit IP address- due to the nature of the
> workload it's very difficult to know which IPs will be hit at any
> given moment.   What I did see in the full IP captures is that the
> returning ACKs don't show up in the packet capture.  Unfortunately,
> tcpdump reported that some packets were dropped during the capture.
> Is it possible that the kernel was dropping the packets before they
> could be captured by tcpdump?

Yes it can happens, because an active sniffer makes the stack using mor=
e
  cpu cycles (timestamping for example).

So you see outgoing SYN packets, but no SYN replies coming from the rem=
ote=20
peer ?  (you mention ACKS, but the first packet received from the remot=
e
  peer should be a SYN+ACK),

client->server   SYN
server->client   SYN+ACK
client->server   ACK


>=20
> Also, I have some doubts about it being the end points or an
> intermediate router, please let me know if these are unreasonable:
> 1)  We've completely replaced our routing equipment several times in
> the past 4 years... totally different colos, router vendors, firewall
> vendors, firewall rules, etc.
> 2)  It occurs across all remote end points at the exact same time.
> The endpoints are hetrogenous, run brain-dead OS's that don't do any
> DOS detection, reboot at random times of the day, are geographically
> distributed, are on different ISPs, etc. etc.
> 3)  Turning of tcp_sack instantaneously makes the problem go away.  I=
f
> it were endpoints or a router, it seems like a stretch that removing =
a
> single TCP option would make the problem instantly resolve itself in
> so many places other than the originating host.

CC to netdev where linux network guys might have an idea.

When the problem comes, instead of restarting the application, please t=
ake a=20
tcpdump of say 10.000 packets.
Then turn off tcp_sack and take a 2nd tcpdump sample, and make both sam=
ples=20
available to us.

If turning off tcp_sack makes the problem go away, why dont you turn it=
 off=20
all the time ?

