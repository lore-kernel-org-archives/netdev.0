From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] percpu: convert SNMP mibs to new infra
Date: Fri, 3 Apr 2009 19:10:24 +0200
Message-ID: <20090403171024.GG19982@elte.hu>
References: <49D32212.80607@cosmosbay.com> <49D32DC2.9010003@goop.org> <49D33E80.70802@cosmosbay.com> <20090401161218.GB3859@elte.hu> <49D3A0C2.9000403@cosmosbay.com> <49D3B61F.8010507@cosmosbay.com> <49D40323.2020406@gmail.com> <20090402040537.GB30442@elte.hu> <49D4724C.7010200@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tejun Heo <htejun@gmail.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	linux kernel <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:43295 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755479AbZDCRKn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Apr 2009 13:10:43 -0400
Content-Disposition: inline
In-Reply-To: <49D4724C.7010200@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Eric Dumazet <dada1@cosmosbay.com> wrote:

> Ingo Molnar a =E9crit :
> > * Tejun Heo <htejun@gmail.com> wrote:
> >=20
> >> Hello, Eric, Ingo.
> >>
> >> Eric Dumazet wrote:
> >>> diff --git a/arch/x86/include/asm/percpu.h b/arch/x86/include/asm=
/percpu.h
> >>> index aee103b..6b82f6b 100644
> >>> --- a/arch/x86/include/asm/percpu.h
> >>> +++ b/arch/x86/include/asm/percpu.h
> >>> @@ -135,6 +135,9 @@ do {							\
> >>>  #define percpu_read(var)	percpu_from_op("mov", per_cpu__##var)
> >>>  #define percpu_write(var, val)	percpu_to_op("mov", per_cpu__##va=
r, val)
> >>>  #define percpu_add(var, val)	percpu_to_op("add", per_cpu__##var,=
 val)
> >>> +#define indir_percpu_add(var, val)	percpu_to_op("add", *(var), v=
al)
> >>> +#define indir_percpu_inc(var)       percpu_to_op("add", *(var), =
1)
> >>> +#define indir_percpu_dec(var)       percpu_to_op("add", *(var), =
-1)
> >>>  #define percpu_sub(var, val)	percpu_to_op("sub", per_cpu__##var,=
 val)
> >>>  #define percpu_and(var, val)	percpu_to_op("and", per_cpu__##var,=
 val)
> >>>  #define percpu_or(var, val)	percpu_to_op("or", per_cpu__##var, v=
al)
> >> The final goal is to unify static and dynamic accesses but we=20
> >> aren't there yet, so, for the time being, we'll need some interim=20
> >> solutions. I would prefer percpu_ptr_add() tho.
> >=20
> > Yep, that's the standard naming scheme for new APIs: generic to=20
> > specific, left to right.
> >=20
>=20
> Here is a second version of the patch, with percpu_ptr_xxx convention=
,
> and more polished form (snmp_mib_free() was forgoten in previous RFC)
>=20
> Thank you all
>=20
> [PATCH] percpu: convert SNMP mibs to new infra
>=20
> Some arches can use percpu infrastructure for safe changes to mibs.
> (percpu_add() is safe against preemption and interrupts), but
> we want the real thing (a single instruction), not an emulation.
>=20
> On arches still using an emulation, its better to keep the two views
> per mib and preemption disable/enable
>=20
> This shrinks size of mibs by 50%, but also shrinks vmlinux text size
> (minimum IPV4 config)
>=20
> $ size vmlinux.old vmlinux.new
>    text    data     bss     dec     hex filename
> 4308458  561092 1728512 6598062  64adae vmlinux.old
> 4303834  561092 1728512 6593438  649b9e vmlinux.new

Wow, that's pretty impressive!

> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> ---
>  arch/x86/include/asm/percpu.h |    3 +++

Acked-by: Ingo Molnar <mingo@elte.hu>

As far as x86 goes, feel free to pick it up into any of the=20
networking trees, these bits are easily merged and it's probably=20
best if the patch stays in a single piece - it looks compact enough=20
and if it breaks it's going to break in networking code.

	Ingo
