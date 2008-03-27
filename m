From: Daniel Noe <dpn@isomerica.net>
Subject: Re: tx-checksumming for an Intel Corporation 82540EP Gigabit Ethernet
 Controller (Mobile)
Date: Thu, 27 Mar 2008 08:00:28 -0400
Message-ID: <47EB8C5C.7060007@isomerica.net>
References: <200803271144.52812.toralf.foerster@gmx.de>
Reply-To: dpn@isomerica.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-15?Q?Toralf_F=F6rster?= <toralf.foerster@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colobus.isomerica.net ([216.93.242.10]:55056 "EHLO
	colobus.isomerica.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758093AbYC0MJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 08:09:05 -0400
In-Reply-To: <200803271144.52812.toralf.foerster@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Toralf F=F6rster wrote:
> I'm wondering why I have to add this line in my startup scripts :=20
>=20
> $> /usr/sbin/ethtool -K eth0 tx off
> to avoid that all outgoing packets have bad check sums (seen with wir=
eshark).

TCP Checksum offloading defers calculation of the TCP checksums in=20
software, instead passing it off to the card which calculates and=20
inserts the checksums.  This is done for performance reasons - it=20
offloads the CPU and lets the NIC hardware perform the relatively=20
mundane task of calculating the checksum (probably also a battery=20
improvement in your mobile case).

The problem is Wireshark (and other capture software) sees the outgoing=
=20
packets before they go to the hardware and have the correct checksum=20
calculated.  So Wireshark complains about invalid checksums.  There are=
=20
a few solutions:

1) Ignore it.  You know the invalid checksums aren't an issue, just=20
ignore them.  The problem is Wireshark by default highlights them in=20
bright, bright red...

2) Tell Wireshark not to verify the checksums.  See=20
http://wiki.wireshark.org/TCP_Checksum_Verification.  This works if you=
=20
don't really care about the checksums and are looking at other things.=20
If you suspect incorrect checksums, you can always turn off checksum=20
offloading manually.

3) Use a hub (if you still have one lying around :) or a switch with a=20
monitoring port.  That way you have Wireshark running on a neutral thir=
d=20
system which is not part of the TCP conversation at all and thus will=20
see the correct checksums as calculated by the hardware on both ends.=20
This is also the only real solution if you want to check that the=20
hardware is calculating the checksum correctly.

Number 3 is best, but solution 2 is fine if you don't need to know abou=
t=20
the checksums.

Hope that helps.

Cheers,
Dan

--=20
                     /--------------- - -  -  -   -   -
                    |  Daniel Noe
                    |  http://isomerica.net/~dpn/
