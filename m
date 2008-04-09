From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [TOMOYO #7 30/30] Hooks for SAKURA and TOMOYO.
Date: Wed, 09 Apr 2008 08:49:17 -0400
Message-ID: <1207745357.21223.391.camel@moss-spartans.epoch.ncsc.mil>
References: <20080404122242.867070732@I-love.SAKURA.ne.jp>
	 <20080404122408.986477936@I-love.SAKURA.ne.jp>
	 <200804071140.59247.paul.moore@hp.com>  <47FC8052.9070409@nttdata.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Paul Moore <paul.moore@hp.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Kentaro Takeda <takedakn@nttdata.co.jp>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>
To: Toshiharu Harada <haradats@nttdata.co.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <47FC8052.9070409@nttdata.co.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed, 2008-04-09 at 17:37 +0900, Toshiharu Harada wrote:
> On 4/8/2008 12:40 AM, Paul Moore wrote:
> > On Friday 04 April 2008 8:23:12 am Tetsuo Handa wrote:
> >> This file contains modifications against kernel source code
> >> needed to use TOMOYO Linux 1.6.
> >>
> >> Although LSM hooks are provided for performing access control,
> >> TOMOYO Linux 1.6 doesn't use LSM because of the following reasons.
> >=20
> > Hello,
> >=20
> > I understand your frustration with the existing LSM hooks/API and y=
our=20
> > reasoning for abandoning LSM in favor of a new set of hooks, howeve=
r, I=20
> > think this sets a dangerous precedence which could result in an=20
> > abundance of security related hooks scattered throughout the kernel=
=2E  I=20
> > would much rather see the LSM API extended/tweaked to support the n=
eeds=20
> > of SAKURA and TOMOYO than ignored and duplicated; I suspect several=
=20
> > others will say the same.
> >=20
> > You have made good progress with TOMOYO so far and if I can remembe=
r=20
> > correctly you really only have one hurdle left, the VFS portion. =20
> > Please continue to seek a solution to this that fits within the LSM=
=20
> > framework.
> >=20
> > Thank you.
>=20
> Thank you for your comments and concern.
>=20
> I realized that we should have included the reason why we decided to
> post non-LSM version. Let me explain the reason and the history.
>=20
> We started developing TOMOYO Linux as original patch sets against
> 2.4 vanilla kernel. We understand the role of LSM, so we ported
> TOMOYO Linux to use LSM and submitted it to the LKML on 13 June 2007.
> We kept working to reflect feedbacks from the community and believe
> no critical Nack remains.
>=20
> http://lwn.net/Articles/238049/
> http://lwn.net/Articles/246930/
> http://lwn.net/Articles/252652/
> http://lwn.net/Articles/254503/
> http://lwn.net/Articles/258905/
> http://lwn.net/Articles/263179/
> http://lwn.net/Articles/264187/
> http://lwn.net/Articles/276603/
>=20
> Still there remains an issue of LSM limitation (vfsmount parameter
> isn=E2=80=99t passed to LSM).
>=20
> LWN article 239962 says, "At the 2006 summit, Linus took a clear
> position that the use of pathnames for security policies seemed
> reasonable to him". Current LSM implementation is sufficient for SELi=
nux
> and other label based MACs but not for pathname-based MACs.
> This has been argued in the AppAmor thread for quite a long time.
> Though proposals had been posted by AppArmor and TOMOYO Linux project=
,
> none has been merged until now.
>=20
> We apologize for the confusion we caused in the last posting,
> but we don't want to give up returning our work to the mainline.=20
>=20
> We cordially request LSM changes to pass vfsmount parameters.

Don't cordially request it - submit patches to make it happen.  Or work
with others who have been submitting such patches.

There are two options:
1) Submit patches to pass down the vfsmounts to the vfs helpers so that
they can be passed to the existing security_inode hooks. -or-
2) Submit patches to add new security hooks to the callers where the
vfsmount is already available (some have suggested moving the existing
security_inode hooks to the callers, but that would cause problems for
SELinux as I've posted elsewhere, so adding new hooks is preferable, an=
d
then SELinux can just default to the dummy functions for those new
hooks).

--=20
Stephen Smalley
National Security Agency

--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
