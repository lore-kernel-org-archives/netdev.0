From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Question on "net: allocate skbs on local node"
Date: Thu, 07 Apr 2011 07:16:52 +0200
Message-ID: <1302153412.2701.64.camel@edumazet-laptop>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>
	 <1302152327.2701.50.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Wei Gu <wei.gu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37501 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390Ab1DGFQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 01:16:57 -0400
Received: by wya21 with SMTP id 21so1895567wya.19
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2011 22:16:56 -0700 (PDT)
In-Reply-To: <1302152327.2701.50.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 07 avril 2011 =C3=A0 06:58 +0200, Eric Dumazet a =C3=A9crit :
> Le jeudi 07 avril 2011 =C3=A0 10:16 +0800, Wei Gu a =C3=A9crit :
> > Hi Eric,
> > Testing with ixgbe Linux 2.6.38 driver:
> > We have a little better thruput figure with this driver, but it loo=
ks
> > not scalling at all, I always stressed one CPU core/24.
> > And when look the perf report for ksoftirqd/24, the most cost funct=
ion
> > is still "_raw_spin_unlock_irqstore" and the IRQ/s is huge, it's
> > somehow conflicts with desgin of NAPI. On linux 2.6.32 while the CP=
U
> > was stressed the IRQ will descreased while the NAPI will running mu=
ch
> > on the polling mode. I don't know why on 2.6.38 the IRQ was keep
> > increasing.
>=20
>=20
> CC netdev and Intel guys, since they said it should not happen (TM)
>=20
> IF you dont use DCA (make sure ioatdma module is not loaded), how com=
es
> alloc_iova() is called at all ?
>=20
> IF you use DCA, how comes its called, since the same CPU serves a giv=
en
> interrupt ?
>=20
>=20

But then, maybe you forgot to cpu affine IRQS ?

High performance routing setup is tricky, since you probably want to
disable many features that are ON by default : Most machines act as a
end host.



