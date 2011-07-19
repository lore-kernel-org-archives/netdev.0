From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: filter: BPF 'JIT' compiler for PPC64
Date: Tue, 19 Jul 2011 11:06:08 +0200
Message-ID: <1311066368.2375.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4E23E5C3.1070209@ozlabs.org>  <4E24E867.9050909@ozlabs.org>
	 <1311058260.16961.12.camel@edumazet-laptop>
	 <1311062135.25044.409.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Evans <matt@ozlabs.org>, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44972 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752456Ab1GSJGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 05:06:18 -0400
Received: by wwe5 with SMTP id 5so3974874wwe.1
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 02:06:16 -0700 (PDT)
In-Reply-To: <1311062135.25044.409.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 19 juillet 2011 =C3=A0 17:55 +1000, Benjamin Herrenschmidt a =C3=
=A9crit :
> On Tue, 2011-07-19 at 08:51 +0200, Eric Dumazet wrote:
>=20
> > > +		case BPF_S_ANC_CPU:
> > > +#ifdef CONFIG_SMP
> > > +			/*
> > > +			 * PACA ptr is r13:
> > > +			 * raw_smp_processor_id() =3D local_paca->paca_index
> > > +			 */
> >=20
> > This could break if one day linux supports more than 65536 cpus :)
> >=20
> > > +			PPC_LHZ_OFFS(r_A, 13,
> > > +				     offsetof(struct paca_struct, paca_index));
> > > +#else
> > > +			PPC_LI(r_A, 0);
> > > +#endif
> > > +			break;
>=20
> As would our implementation of raw_smp_processor_id() and our
> spinlocks :-) I don't think we need to fix that -now- but you are
> welcome to add something like a
> BUILD_BUG_ON(sizeof(local_paca->paca_index) !=3D 2); as a reminder :-=
)

Please Matt add to your next version this check. I dont think I have to
submit a one line patch later...

On x86_64, cpu_number field is already 32bit, we have some time before
it becomes 64bit ;)

We probably should add some extra check to make sure segment doesnt
change (%gs on x86_64, r13 on ppc64) on a future linux version.



