From: Wolfgang Walter <wolfgang.walter@stwm.de>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Thu, 7 Aug 2008 02:38:58 +0200
Message-ID: <200808070238.58959.wolfgang.walter@stwm.de>
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
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:44618 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753389AbYHGAjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 20:39:01 -0400
In-Reply-To: <20080806212152.GB607@linux-os.sc.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for your answer.

On Wednesday 06 August 2008, Suresh Siddha wrote:
> On Wed, Aug 06, 2008 at 01:14:02PM -0700, Siddha, Suresh B wrote:
> > On Wed, Aug 06, 2008 at 10:33:25AM -0700, Wolfgang Walter wrote:
> > > Hello Herbert,
> > >
> > > I think I finally found the problem.
> > >
> > > Here a short description again: all our routers with a via C3 usi=
ng=20
> > > padlock for AES-encryption are
> > > crashing with 2.6.26 while they work fine with 2.6.25. Not using =
padlock
> > > (i.e. using the i386 assembler version of AES) they just work fin=
e.
> >=20
> > Both the padlock version or asm version don't use FP/math registers=
,=20
> > right?
> > It is interesting that you don't see the problem with asm version
> > but see the problem with padlock version.

I don't know how padlock exactly works and I don't know anything of i38=
6's=20
architecture on hardware and assembler level. So I can only speculate:

Maybe padlock aes does influence FP/math.

http://linux.via.com.tw/support/beginDownload.action?eleid=3D181&fid=3D=
261

states:

3. SSE instructions must be enabled via the standard x86 method of enab=
ling
the FXSAVE/FXRSTOR instructions using CR4[9] This enables the full set =
of SSE
instructions. If CR4[9] is not set, PadLock behaves as if it were disab=
led via
the MSR, regardless of the setting of the enable bits MSRs.


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
> Similarly, if the status field(in thread_info) gets corrupted(setting
> TS_USEDFPU) without proper math state allocated(present in thread_str=
uct),
> we can end up oops in __switch_to.
>=20
> But you seem to say, reverting recent fpu patches make the problem go=
 away.
> hmm, just wondering if your test kernel (with fpu patches reverted) i=
s=20
stable
> enough and don't see other oops/issues?

No oops yet.

2.6.26 crashes here within 1 or 2 minutes if (and only) if there is ips=
ec=20
traffic using padlock aes and there are actually processes running (i.e=
=2E=20
ssh).

The modified 2.6.26 did not crash yet (now running hours).

Unmodified 2.6.26 where we use i386 assembler aes instead of padlock ru=
ns=20
since 2 weeks.

We further use almost same kernels (only compiled for K7 or Intel Core =
Duo,=20
respectively) on K7 and an Intel Quad Core without problems.

>=20
> Recently Vegard also noticed some stack corruptions (in network stack=
)=20
leading
> to similar problems. Not sure if Vegard has root caused his issue. co=
pying=20
him
> for his comments.
>=20
> thanks,
> suresh
>=20
>=20

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
