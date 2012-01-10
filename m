From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: CPU usage for IPSec in Linux 2.6.38
Date: Tue, 10 Jan 2012 16:24:32 +0100
Message-ID: <1326209072.19095.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <B97B134FACB2024DB45F524AB0A7B7F20545EA24@XMB-BGL-419.cisco.com>
	<20203.19901.967544.547378@fireball.kivinen.iki.fi>
	<B2C779B5E2D74D1792EB988E1B59B42B@trustworks.com>
	 <A2354B6A9F807641B21EEABD666ECEEA02596D7C@XMB-BGL-416.cisco.com>
	 <09787EF419216C41A903FD14EE5506DD030F1A4FDA@AUSX7MCPC103.AMER.DELL.COM>
	 <A2354B6A9F807641B21EEABD666ECEEA02596D98@XMB-BGL-416.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Naveen B N (nbn)" <nbn@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:65134 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756Ab2AJPYh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2012 10:24:37 -0500
Received: by wgbdr10 with SMTP id dr10so3171517wgb.1
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2012 07:24:36 -0800 (PST)
In-Reply-To: <A2354B6A9F807641B21EEABD666ECEEA02596D98@XMB-BGL-416.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 10 janvier 2012 =C3=A0 20:23 +0530, Naveen B N (nbn) a =C3=A9c=
rit :
> Hi All,
> I am using linux 2.6.36 kernel and trying to add 6000 Ikev2/ipsec
> tunnels at 20 Ikev2 messages per second , I am using netlink socket
> which is set to NON_BLOCKING and i am sending XFRM SPD added for ever=
y
> successful AUTH message received.
>=20
> But the problem is after the 4000 tunnels are established, CPU usage
> goes to > 90%, which will likely cause dropping of few AUTH response
> from responder.
>=20
> NOTE:
> But when I disabled adding SPD messaged via netlink sockets using xfr=
m
> messages, I am able to complete 6000 ikev2 SA negotiation successfull=
y.
>=20
> So the problem i am seeing is when sending XFRM netlink message > 400=
0.
>=20
> Any solutions are or analysis different then the above is appreciated=
=2E
>=20

Most probably something uses a linear search, giving O(N^2) complexity.

You could post "perf top" results while doing these operations.
