From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [regression] 2.6.37+ commit 0363466866d9.... breaks tcp ipv6
Date: Fri, 21 Jan 2011 20:55:45 +0100
Message-ID: <1295639745.2609.29.camel@edumazet-laptop>
References: <4D335417.80704@xmsnet.nl>	<4D35EF64.1040906@xmsnet.nl>
	 <AANLkTinejKw0pY5HncB2e0ocjqYuCwTBUwd2xkroWu+E@mail.gmail.com>
	 <4D36092B.1090406@xmsnet.nl> <1295388238.8449.10.camel@edumazet-laptop>
	 <4D39E2EC.9020906@xmsnet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Gross <jesse@nicira.com>, netdev <netdev@vger.kernel.org>
To: Hans de Bruin <jmdebruin@xmsnet.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34207 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752903Ab1AUTzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 14:55:50 -0500
Received: by wwa36 with SMTP id 36so2261779wwa.1
        for <netdev@vger.kernel.org>; Fri, 21 Jan 2011 11:55:49 -0800 (PST)
In-Reply-To: <4D39E2EC.9020906@xmsnet.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 21 janvier 2011 =C3=A0 20:47 +0100, Hans de Bruin a =C3=A9c=
rit :
> On 01/18/2011 11:03 PM, Eric Dumazet wrote:
> > Le mardi 18 janvier 2011 =C3=A0 22:42 +0100, Hans de Bruin a =C3=A9=
crit :
> >> On 01/18/2011 09:06 PM, Jesse Gross wrote:
>=20
> ...
>=20
> > You could try "tcpdump -i eth0 ip6 -v"
> >
> > I guess you receive frames with bad checksums
>=20
> While you where staring at the code, I was fooling around with tcpdum=
p.=20
> And while the problem is fixed, I still have some questions:
>=20
> Is there tool which shows whether a nic supports ipv6 checksum offloa=
d=20
> or not?
>=20
> I have captured http traffic (wget http://bootes/) between psion (my =
git=20
> tree following laptop) and bootes (something running 2.6.33.7).
> Attached is a capture with psion running 2.6.37 and one with this=20
> morning's git tree. Wat's with the 'chsum ... ( incorrect -> ' lines =
?
> ifconfig does not show errors on either of the machines.
>=20

tcpdump gets a copy of outgoing frames before NIC performs tx checksum
(if tx checksum handled by NIC), so it's normal to have "bad checksums"
on TX, unless you disable tx offloading (ethtool -K eth0 tx off)

I was referring to check with tcpdump incoming frames, because invalid
checksums in RX is sign that other peer sent wrong checksums



