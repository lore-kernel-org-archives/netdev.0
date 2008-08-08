From: Wolfgang Walter <wolfgang.walter@stwm.de>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Fri, 8 Aug 2008 10:44:01 +0200
Message-ID: <200808081044.01470.wolfgang.walter@stwm.de>
References: <200807171653.59177.wolfgang.walter@stwm.de> <20080806201401.GA607@linux-os.sc.intel.com> <20080806212152.GB607@linux-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>, vegard.nossum@gmail.com
To: Suresh Siddha <suresh.b.siddha@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:59458 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753363AbYHHIoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 04:44:05 -0400
In-Reply-To: <20080806212152.GB607@linux-os.sc.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 06 August 2008, Suresh Siddha wrote:
> On Wed, Aug 06, 2008 at 01:14:02PM -0700, Siddha, Suresh B wrote:
> > On Wed, Aug 06, 2008 at 10:33:25AM -0700, Wolfgang Walter wrote:
> > > Hello Herbert,
> > >
> > > I think I finally found the problem.
> > >
> > > Here a short description again: all our routers with a via C3 usi=
ng=20
padlock for AES-encryption are
> > > crashing with 2.6.26 while they work fine with 2.6.25. Not using =
padlock
> > > (i.e. using the i386 assembler version of AES) they just work fin=
e.
> >=20
> > Both the padlock version or asm version don't use FP/math registers=
,=20
right?
> > It is interesting that you don't see the problem with asm version
> > but see the problem with padlock version.
> >=20
> > Does disabling CONFIG_PREEMPT in 2.6.26 change anything? And also,
> > can you provide the complete kernel log till the point of failure(o=
ops
> > that you sent doesn't have the call trace info)
>=20
> BTW, in one of your oops, I see:
>=20
> note: cron[1207] exited with preempt_count 268435459
>=20
> I smell some kind of stack corruption here which is corrupting
> thread_info (in the above case preempt_count in the thread_info).
>=20

I don't think 268435459 is a strong indication of stack corruption:

268435459 =3D=3D 0x10000003 =3D=3D PREEMPT_ACTIVE|0x03

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
