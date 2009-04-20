From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: bond interface arp, vlan and trunk / network question
Date: Mon, 20 Apr 2009 23:15:53 +0200
Message-ID: <49ECE609.6080400@cosmosbay.com>
References: <1ef444010904201050g72651387se3feca3fbd68ce30@mail.gmail.com>	 <49ECBBF0.80202@cosmosbay.com>	 <30257.1240252651@death.nxdomain.ibm.com>	 <1ef444010904201300r43268672sb74277f4a0242236@mail.gmail.com>	 <7609.1240259780@death.nxdomain.ibm.com> <1ef444010904201403s5d583750i1ce3a5da6c6f4059@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: stefan novak <lms.brubaker@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54425 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756982AbZDTVQB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 17:16:01 -0400
In-Reply-To: <1ef444010904201403s5d583750i1ce3a5da6c6f4059@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

stefan novak a =E9crit :
>>        I believe you're seeing the expected behavior from arping her=
e,
>> and it does not automatically indicate that anything is wrong.
>>
>>        It's very possible that your network topology is such that
>> arping -I bond0 won't work while arping -I bond0.600 does.  If the
>> target you specify is reachable only on the VLAN, it's expected beha=
vior
>> that arping -I bond0 of that target won't work (because the interfac=
e
>> bond0 is not attached to the VLAN, only bond0.600 is).  That doesn't
>> mean that the ARPs generated internally by bonding are untagged /
>> failing, as bonding itself adds VLAN tags to its own ARP probes as
>> needed.
>=20
> Ok. I've checked the tcpdump's on the machines and I think something =
is working.
>=20
> tcpdump  -v -i eth0 arp
> tcpdump: WARNING: eth0: no IPv4 address assigned
> tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size=
 96 bytes
> 22:56:38.817599 arp who-has 172.21.0.254 tell 172.21.0.1
> 22:56:38.847597 arp who-has 172.21.0.254 tell 172.21.0.1
> 22:56:38.877598 arp who-has 172.21.0.254 tell 172.21.0.1
> 22:56:38.907596 arp who-has 172.21.0.254 tell 172.21.0.1
>=20
> tcpdump  -v -i bond0.600 arp
> tcpdump: listening on bond0.600, link-type EN10MB (Ethernet), capture
> size 96 bytes
> 22:56:49.167157 arp reply 172.21.0.254 is-at 00:1d:70:d1:ad:83 (oui U=
nknown)
> 22:56:49.197162 arp reply 172.21.0.254 is-at 00:1d:70:d1:ad:83 (oui U=
nknown)
> 22:56:49.227130 arp reply 172.21.0.254 is-at 00:1d:70:d1:ad:83 (oui U=
nknown)
> 22:56:49.257144 arp reply 172.21.0.254 is-at 00:1d:70:d1:ad:83 (oui U=
nknown)
>=20
> the arp's are sent out on eth0 and recieved via bond0.600. When they
> are sent on eth0 then the switch must tag the vlan600 (private vlan).

Ah, you setup eth0 or bond0 with an IP ?

bond driver does a route loookup to find out if a vlan tag is necessary=
 or not
when issuing an arp request.

So check result of : "ip route get 172.21.0.254"


> Then they come in at the right interface. Is it normal that so many
> arp's are sent?

you setup a 30 ms interval, so you get what you asked for :)

> Is there a way to check if the arp check is working right in the proc
> fs oder something like that?
>=20
>>        Also, are you running multiple blades with bonding behind the
>> same set of switches?
>=20
> Yes, 14 blades with 2 seperate(not connected) switches.
>=20
>>  If you are, you probably want to set the
>> arp_validate option to either "active" or "all", as the default sett=
ing
>> (none) relies only on the existance of traffic on the slaves, and
>> doesn't check the source of that traffic.  The end result of that is=
 the
>> probes from multiple bonding instances fool one another into thinkin=
g
>> the path is up, when it is not.  With arp_validate enabled, it'll ch=
eck
>> that the slaves are actually receiving their own ARP traffic.
>=20
> Ok, sounds right for me. I've set the arp_validate option to "all".

Please give us :

ifconfig -a


