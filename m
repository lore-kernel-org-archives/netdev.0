From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel panic in fib_rules_lookup [2.6.27.7 vendor-patched]
Date: Tue, 26 Oct 2010 16:33:34 +0200
Message-ID: <1288103614.2622.0.camel@edumazet-laptop>
References: <loom.20101012T185411-307@post.gmane.org>
	 <1286905245.2703.3.camel@edumazet-laptop>  <4CBF2A3F.2070108@cox.net>
	 <1287612353.2545.11.camel@edumazet-laptop>  <4CC1F47C.9020104@cox.net>
	 <1287805487.2658.5.camel@edumazet-laptop>
	 <1287846669.2658.247.camel@edumazet-laptop>  <4CC30055.5040509@cox.net>
	 <1287851745.2658.364.camel@edumazet-laptop>  <4CC6D7CC.5040608@cox.net>
	 <1288100208.3169.112.camel@edumazet-laptop>  <4CC6DD69.4020502@cox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Joe Buehler <aspam@cox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:52062 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754095Ab0JZOdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 10:33:42 -0400
Received: by ewy7 with SMTP id 7so5386146ewy.19
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 07:33:41 -0700 (PDT)
In-Reply-To: <4CC6DD69.4020502@cox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 octobre 2010 =C3=A0 09:53 -0400, Joe Buehler a =C3=A9crit :
> Eric Dumazet wrote:
>=20
> > Well, it would be surprising this being wrong and crash only once i=
n a
> > while in fib_rules_lookup
>=20
> > Did you tried my last patch ?
>=20
> There was a patch to the kernel by David Daney back in January to
> improve performance of Octeon memory barriers.  The patch changes the
> generic MIPS barrier code to introduce optimizations for Octeon.  The
> LINUX version I am using is from the Octeon SDK and appears to have a=
n
> early version of this patch.  It's broken however -- the Jan patch ha=
s
> proper SYNCW instructions in smp_wmb while the SDK version does not.
>=20
> I have made your changes but will also fold in this change, then star=
t
> some load testing.
>=20
> The real-time scheduler is broken in the LINUX I am using -- I get
> kernel crashes -- and I would be most happy if the SYNCW fix fixed th=
at
> also.
>=20
>

Just to make sure, are you using a single syncw, or a double one ?

/*
 * We actually use two syncw instructions in a row when we need a write
 * memory barrier. This is because the CN3XXX series of Octeons have
 * errata Core-401. This can cause a single syncw to not enforce
 * ordering under very rare conditions. Even if it is rare, better safe
 * than sorry.
 */
#define CVMX_SYNCW asm volatile ("syncw\n\tsyncw" : : : "memory")





