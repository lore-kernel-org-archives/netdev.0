From: Arkadiusz Miskiewicz <arekm@maven.pl>
Subject: Re: htb and UDP packages bigger than 1500
Date: Tue, 11 Dec 2007 09:48:19 +0100
Message-ID: <200712110948.19504.arekm@maven.pl>
References: <20071211081929.GA2261@ff.dom.local> <200712110917.30945.arekm@maven.pl> <20071211083559.GB2261@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.carme.maven.pl ([193.239.45.138]:18179 "EHLO
	main.carme.maven.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750735AbXLKIsZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 03:48:25 -0500
In-Reply-To: <20071211083559.GB2261@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 11 of December 2007, Jarek Poplawski wrote:
> On Tue, Dec 11, 2007 at 09:17:30AM +0100, Arkadiusz Miskiewicz wrote:
> > On Tuesday 11 of December 2007, Jarek Poplawski wrote:
> > > On 10-12-2007 18:10, Arkadiusz Miskiewicz wrote:
> > > > Hello,
> > > >
> > > > I noticed that HTB doesn't properly limit traffic if someone se=
nds
> > > > UDP packages bigger than 1500.
> > > >
> > > > Does HTB have some problems/known limits in this area?
> > > >
> > > > There is other traffic in that class and when I drop udp packet=
s
> > > > bigger than 1500 then remaining traffic is limited properly to
> > > > correct value.
> > >
> > > Should work with proper "mtu" parameter (tc qdisc add htb help) o=
r,
> > > for kernels >=3D 2.6.23, even without this. If this doesn't help,
> > > probably more information is required.
> >
> > 2.6.22 there. mtu wasn't specified at tc... Could you point to a gi=
t
> > commit which "fixes" the issue in 2.6.23 so I could backport it to =
my
> > 2.6.22?
>
> http://git.kernel.org/?p=3Dlinux/kernel/git/stable/linux-2.6.23.y.git=
;a=3Dcommi
>tdiff;h=3Dc9726d6890f7f3a892c879e067c3ed839f61e745
>
> From: Ranjit Manomohan <ranjitm@google.com>
> Date: Wed, 11 Jul 2007 05:43:16 +0000 (-0700)
> Subject: [NET_SCHED]: Make HTB scheduler work with TSO.
> X-Git-Tag: v2.6.23-rc1~1109^2~22

Backported.

> But this is done with two different ways. And btw., if there is such
> a big difference in sizes it could be not very accurate after all.

Hm, here htb qdisc is attached to imq devices which have mtu 16000 by d=
efault=20
(in latest patch; previously that was 1500). I'll just lower it to 1500=
 for=20
now. Thanks.

> Jarek P.

--=20
Arkadiusz Mi=B6kiewicz        PLD/Linux Team
arekm / maven.pl            http://ftp.pld-linux.org/
