From: Wolfgang Walter <wolfgang.walter@stwm.de>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Sat, 9 Aug 2008 04:43:00 +0200
Message-ID: <200808090443.00597.wolfgang.walter@stwm.de>
References: <200807171653.59177.wolfgang.walter@stwm.de> <489C97FB.2030408@zytor.com> <20080809014925.GA26529@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	Suresh Siddha <suresh.b.siddha@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>, viro@zeniv.linux.org.uk,
	vegard.nossum@gmail.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:54610 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750890AbYHICnE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 22:43:04 -0400
In-Reply-To: <20080809014925.GA26529@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 09 August 2008, Herbert Xu wrote:
> On Fri, Aug 08, 2008 at 12:01:15PM -0700, H. Peter Anvin wrote:
> >
> > It's technically overkill, if (and only if!) these instructions don=
't=20
> > actually touch the SSE state (most likely they're using the SSE=20
> > pipeline, and need this stuff to deal with power management issues.=
)
>=20
> Yes the PadLock uses the SSE pipeline, but doesn't touch any
> of the state.
>=20
> > However, overkill is a good way to make sure something is dead.=20
> > Applying the patch will make sure we fix the regression, and we can=
=20
> > worry about optimizing this further post-2.6.27.
>=20
> Do we really need the FPU changes right now? I'd prefer for that
> to be backed out until a proper solution is found.  Disabling
> preemption around crypto is really bad for scheduling latency.
>=20

These FPU changes are already in 2.6.26. Undoing them, would that be ac=
cepted=20
for 2.6.26 stable?

Maybe the following solution would be possible: if a processor with pad=
lock is=20
detected the memory for xstate is always allocated when the thread is c=
reated=20
instead "lazy"?

Or would it be possible to change __switch_to(): bevor calling __unlazy=
_fpu()=20
check if xstate is NULL, if yes, clear TS_USEDFPU and math-state?


As I wrote in my other mail: 2.6.26 with the patch seems to perform rat=
her=20
well with ipsec. Network latency and bandwidth seem completely unchange=
d=20
compared to 2.6.15.13 as far as I can see yet.

But this is of course not a good test for kernel latency itself. As we =
don't=20
have any destops based on VIA C3 (and these using padlock) I can't real=
ly=20
test this (even if I set one up I don't know how it used to feel with=20
2.6.25 :-) ).=20

But I doubt that a lot of people use it as a desktop together with a VI=
A C3=20
and ipsec. If they would they must see this crash.


Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
Leiter EDV
Leopoldstra=DFe 15
80802 M=FCnchen
Tel: +49 89 38196-276
=46ax: +49 89 38196-144
wolfgang.walter@stwm.de
http://www.studentenwerk-muenchen.de/
