From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Question on "net: allocate skbs on local node"
Date: Thu, 07 Apr 2011 08:16:52 +0200
Message-ID: <1302157012.2701.73.camel@edumazet-laptop>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>
	 <1302152327.2701.50.camel@edumazet-laptop>
	 <1302153412.2701.64.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Wei Gu <wei.gu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53723 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046Ab1DGGQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 02:16:57 -0400
Received: by wwa36 with SMTP id 36so2631960wwa.1
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2011 23:16:56 -0700 (PDT)
In-Reply-To: <1302153412.2701.64.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 07 avril 2011 =C3=A0 07:16 +0200, Eric Dumazet a =C3=A9crit :
> Le jeudi 07 avril 2011 =C3=A0 06:58 +0200, Eric Dumazet a =C3=A9crit =
:
> > Le jeudi 07 avril 2011 =C3=A0 10:16 +0800, Wei Gu a =C3=A9crit :
> > > Hi Eric,
> > > Testing with ixgbe Linux 2.6.38 driver:
> > > We have a little better thruput figure with this driver, but it l=
ooks
> > > not scalling at all, I always stressed one CPU core/24.
> > > And when look the perf report for ksoftirqd/24, the most cost fun=
ction
> > > is still "_raw_spin_unlock_irqstore" and the IRQ/s is huge, it's
> > > somehow conflicts with desgin of NAPI. On linux 2.6.32 while the =
CPU
> > > was stressed the IRQ will descreased while the NAPI will running =
much
> > > on the polling mode. I don't know why on 2.6.38 the IRQ was keep
> > > increasing.
> >=20
> >=20
> > CC netdev and Intel guys, since they said it should not happen (TM)
> >=20
> > IF you dont use DCA (make sure ioatdma module is not loaded), how c=
omes
> > alloc_iova() is called at all ?
> >=20
> > IF you use DCA, how comes its called, since the same CPU serves a g=
iven
> > interrupt ?
> >=20
> >=20
>=20
> But then, maybe you forgot to cpu affine IRQS ?
>=20
> High performance routing setup is tricky, since you probably want to
> disable many features that are ON by default : Most machines act as a
> end host.
>=20
>=20

Please dont send me anymore private mails, I do think the issue you hav=
e
is on a setup, not a particular optimization done in network stack.


Copy of your private mail :

> On 2.6.38, I got a lot of "rx_missed_errors" on NIC, which means the
> rx loop was really busy to get packet from the receiving ring. Usuall=
y
> in this case it shouldn't exit the softirqs and keep polling in order
> to decrease the initrs.
>=20
> On 2.6.32, I can Rx and Tx 2.3Mpps with no packet lost(error on NIC),
> but on 2.6.38 I can only reach 50kpps with a lot of
> "rx_missed_errors", and all the binding cpu core was 100% in SI. I
> don't think there was any optimizations on it.

I hope you understand there is something wrong with your setup ?

50.000 pps on a 64 cpu machine is a bad joke.

We can reach +10.000.000 on a 16 cpus one.



