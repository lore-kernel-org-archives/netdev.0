From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Thu, 14 Apr 2011 19:49:16 +0200
Message-ID: <1302803357.2744.1.camel@edumazet-laptop>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>
	 <1302253651.4409.2.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA66B@ESGSCCMS0001.eapac.ericsson.se>
	 <1302267400.4409.22.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA682@ESGSCCMS0001.eapac.ericsson.se>
	 <1302275223.4409.36.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA6AE@ESGSCCMS0001.eapac.ericsson.se>
	 <1302330998.2656.113.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA730@ESGSCCMS0001.eapac.ericsson.se>
	 <4DA3151B.4030507@intel.com>
	 <D12839161ADD3A4B8DA63D1A134D084026E4909714@ESGSCCMS0001.eapac.ericsson.se>
	 <1302536577.4605.1.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E49535F2@ESGSCCMS0001.eapac.ericsson.se>
	 <1302761251.3549.198.camel@edumazet-laptop>
	 <1302762810.3549.233.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E49536AF@ESGSCCMS0001.eapac.ericsson.se>
	 <4DA723F1.7000901@intel.com>  <1302800202.2035.32.camel@laptop>
	 <1302800221.3248.39.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	Wei Gu <wei.gu@ericsson.com>, netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Mike Galbraith <efault@gmx.de>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50753 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933379Ab1DNRtW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 13:49:22 -0400
Received: by wwa36 with SMTP id 36so2308483wwa.1
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2011 10:49:21 -0700 (PDT)
In-Reply-To: <1302800221.3248.39.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 14 avril 2011 =C3=A0 18:57 +0200, Eric Dumazet a =C3=A9crit :
> Le jeudi 14 avril 2011 =C3=A0 18:56 +0200, Peter Zijlstra a =C3=A9cri=
t :
> > On Thu, 2011-04-14 at 09:42 -0700, Alexander Duyck wrote:
> >=20
> > > I'm doing some more digging into this now.  One thought that occu=
rred to=20
> > > me is that if the patch you mention is having some sort of effect=
 this=20
> > > could be a sign of perhaps a kernel timer or scheduling problem.
> >=20
> > Right, so the removal of the NO_HZ throttle will allow the CPU to g=
o
> > into C states more often, this could result in longer wake-up times=
 for
> > IRQs.
> >=20
> > We reverted because:
> >   - it caused significant battery drain due to not going into C sta=
tes
> >     often enough, and
> >   - its a much better idea to implement these things in the idle
> >     governor since it already has the job of guestimating the idle
> >     duration.
> >=20
> > I really can't remember back far enough to even come up with a theo=
ry of
> > why kernels prior to merging the NO_HZ throttle would not exhibit t=
his
> > problem.
> >=20
> >=20
> >=20
>=20
> Normally, Wei Gu already asked to not use C states.
>=20
> http://h20000.www2.hp.com/bc/docs/support/SupportManual/c01804533/c01=
804533.pdf
>=20
> How can we/he check this ?
>=20
>=20

Anyway, this could explain a latency problem, not packet drops.

With NAPI, we should get few hardware irqs under load.

Once softirq started, scheduler is out of the equation.



