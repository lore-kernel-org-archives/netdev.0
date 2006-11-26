From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: gratuitous arp
Date: Sun, 26 Nov 2006 14:52:26 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0611261417200.5650@bizon.gios.gov.pl>
References: <Pine.LNX.4.64.0611251526040.8068@twinlark.arctic.org>
 <4568F663.7090805@superbug.co.uk> <Pine.LNX.4.64.0611251819310.8068@twinlark.arctic.org>
 <456991D9.7000503@superbug.co.uk>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-911214150-1164549146=:5650"
Cc: dean gaudet <dean@arctic.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:16092 "EHLO
	bizon.gios.gov.pl") by vger.kernel.org with ESMTP id S935392AbWKZNwg
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Nov 2006 08:52:36 -0500
To: James Courtier-Dutton <James@superbug.co.uk>
In-Reply-To: <456991D9.7000503@superbug.co.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-911214150-1164549146=:5650
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Sun, 26 Nov 2006, James Courtier-Dutton wrote:

> dean gaudet wrote:
>> On Sun, 26 Nov 2006, James Courtier-Dutton wrote:
>>=20
>>> dean gaudet wrote:
>>>> hi...
>>>>=20
>>>> i ran into some problems recently which would have been avoided if my =
box
>>>> did a gratuitous arp as it brought up all interfaces (the router took
>>>> forever to timeout the ARP entries for interface aliases).  so i set=
=20
>>>> about
>>>> looking to see why that wasn't happening.
>> ...
>>> Are you 100% sure about this?
>>> Have you done a packet sniff on the network?
>>> A lot of routers ignore gratuitous arp for security reasons.
>>=20
>> yeah i've done some packet sniffing to verify this.
>>=20
>> here's what happened (twice now):  i upgraded a (normally busy) box, so =
the=20
>> MAC address changed.  the router is a cisco (not managed by me).
>>=20
>> debian reboot sequence at some point brings up the primary eth0 address =
and=20
>> very soon thereafter there will be an arp "who-has $default_gw tell=20
>> $primary_addr".  that's sufficient to get the cisco to update its ARP ca=
che=20
>> for $primary_addr.  this isn't gratuitous arp, but does the trick for th=
e=20
>> $primary_addr.
>>=20
>> but there's no gratuitous arp for any eth0:N aliased interfaces... and t=
he=20
>> cisco ARP cache on this ISP router seems to be set to a long timeout.  i=
=20
>> could reach eth0:N from local net, but couldn't get outside local net fr=
om=20
>> eth0:N.
>>=20
>> issuing "arping -I eth0 -s $secondary_addr $default_gw" for each seconda=
ry=20
>> address updated the cisco ARP cache and i could then reach eth0:N remote=
ly.
>>=20
>> so... that may not be exactly gratuitous arp, but basically i was stuck=
=20
>> until i forced the cisco to update its ARP cache for each of the seconda=
ry=20
>> addrs...
>>=20
>> it seems to me it'd be nice for the init sequence to take care of this, =
so=20
>> that other folks don't have to spend time debugging similar problems.  i=
=20
>> just wanted to ask if i'm missing something obvious before i go open a=
=20
>> debian bug.  (i'm tempted to see if fedora does anything differently.)
>>=20
>> thanks
>> -dean
>
> Ok, I think it is better to just do gratuitous arp on the primary interfa=
ce.
> If one starts doing it on secondary interfaces, one would then have to al=
so=20
> do it for all proxy-arp addresses(if used), and thinks could start gettin=
g=20
> rather messy.

BTW: There is no such thing like secondary interfaces. What you use=20
(ethX:X) is emulation of interface aliases that was necessary for linux=20
2.2.x, more than 5 yers ago. Currently (2.4/2.6) it is possible to add=20
many addressess to one interface - all you need is the iproute2 package=20
and utility called "ip".

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-911214150-1164549146=:5650--
