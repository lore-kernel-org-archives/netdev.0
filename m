From: "Stefan Lippers-Hollmann" <s.L-H@gmx.de>
Subject: Re: [PATCH] r8169: revert "add byte queue limit support".
Date: Fri, 27 Jul 2012 05:36:45 +0200
Message-ID: <201207270536.50292.s.L-H@gmx.de>
References: <20120723205555.GA4392@electric-eye.fr.zoreil.com> <1343106407.2626.11038.camel@edumazet-glaptop> <20120724053811.GA12053@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, hayeswang@realtek.com,
	netdev@vger.kernel.org,
	Alex =?utf-8?q?Villac=C3=ADs_Lasso?= <a_villacis@palosanto.com>,
	Josh Boyer <jwboyer@redhat.com>,
	Tom Herbert <therbert@google.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p05-ob.rzone.de ([81.169.146.180]:39959 "EHLO
	mo-p05-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752914Ab2G0DhB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 23:37:01 -0400
In-Reply-To: <20120724053811.GA12053@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

On Tuesday 24 July 2012, Francois Romieu wrote:
> Eric Dumazet <eric.dumazet@gmail.com> :
> > On Mon, 2012-07-23 at 22:55 +0200, Francois Romieu wrote:
> > > This reverts commit 036dafa28da1e2565a8529de2ae663c37b7a0060.
> [...]
> > bisection is not always the right way to qualify a problem.
>=20
> I know. At some point I switch from "I could search more" to "users s=
ituation
> will improve in a definite timeframe".
>=20
> > BQL in itself had some fixes coming _after_ commit 036dafa28da1e256=
5
>=20
> Thanks.
>=20
> They are in stable as of 3.4.5:
[=E2=80=A6]
> I have obviously not directed users at them and I do not see any
> of the victims using a non -stable / -vendor or recent enough
> kernel to test this patch since the issue has been reported.
>=20
> They are both worth testing.
[=E2=80=A6]

3.4.x up to and including 3.4.4 exposed the problem on these cards[1]:

r8169 0000:04:00.0: eth0: RTL8168d/8111d at 0xffffc90000c72000, 00:24:1=
d:72:7c:75, XID 081000c0 IRQ 44
r8169 0000:05:00.0: eth1: RTL8168d/8111d at 0xffffc90000c70000, 00:24:1=
d:72:7c:77, XID 081000c0 IRQ 45

while it is stable with "add byte queue limit support" reverted; 3.4.5+
was only tested with 036dafa28da1e2565a8529de2ae663c37b7a0060 reverted.

Now testing plain 3.5.0, which still includes it, has been reliable for
almost 3 days - while the issue usually triggered within one hour (3=20
hours at most) in 3.4.[0-4]. It might be a little too early to give a
definitive answer, but so far r8169/ 3.5.0 looks positive.

Regards
	Stefan Lippers-Hollmann

[1]	Message-Id: <201206290131.49150.s.L-H@gmx.de>
	http://lkml.kernel.org/r/<201206290131.49150.s.L-H@gmx.de>
