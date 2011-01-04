From: "Sebastian J. Bronner" <sebastian.bronner@d9t.de>
Subject: Re: bridge not routing packets via source bridgeport
Date: Tue, 04 Jan 2011 09:25:52 +0100
Message-ID: <4D22D990.7030409@d9t.de>
References: <4D220CFB.5060300@d9t.de> <1294080135.2892.1152.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Daniel Kraft <daniel.kraft@d9t.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj232.sb.d9t.de ([94.186.148.168]:54819 "EHLO
	zimbra.pool.b.d9tcloud.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752371Ab1ADIZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 03:25:58 -0500
In-Reply-To: <1294080135.2892.1152.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03.01.2011 19:42, Eric Dumazet wrote:
> Le lundi 03 janvier 2011 =C3=A0 18:52 +0100, Sebastian J. Bronner a =C3=
=A9crit :
>> we recently upgraded from 2.6.32.25 to 2.6.35.24 and discovered that=
 our
>> virtual machines can no longer access their own external IP addresse=
s.
>> Testing revealed that 2.6.34 was the last version not to have the
>> problem. 2.6.36 still had it. But on to the details.

[ Details snipped ]

> random guess: maybe rp_filter hits you ?
>=20
>=20
> With 2.6.36, a new SNMP counter was added,=20
> "netstat -s | grep IPReversePathFilter"

Thanks for your guess, Eric.

Unfortunately, that didn't change anything.

According to the documentation at

http://lartc.org/howto/lartc.kernel.html

that parameter is to prevent _responses_ leaving through a different
interface that the original packet came in on. So, I wouldn't expect it
to have any impact on _routed packets_.

In my original e-mail, I forgot to mention something I noticed while
debugging:

If i put the bridge into promiscuous mode, then suddenly the packets ar=
e
routed.

# ip link set promisc on dev virbr1

Cheers,
Sebastian
--=20
*Sebastian J. Bronner*
Administrator

D9T GmbH - Magirusstr. 39/1 - D-89077 Ulm
Tel: +49 731 1411 696-0 - Fax: +49 731 3799-220

Gesch=C3=A4ftsf=C3=BChrer: Daniel Kraft
Sitz und Register: Ulm, HRB 722416
Ust.IdNr: DE 260484638

http://d9t.de - D9T High Performance Hosting
info@d9t.de
