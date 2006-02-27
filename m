From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] Revert sky2 to 0.13a
Date: Mon, 27 Feb 2006 08:00:42 -0800
Message-ID: <20060227080042.0cf3f05d@localhost.localdomain>
References: <4400FC28.1060705@gmx.net>
	<200602261913.36308.woho@woho.de>
	<200602262331.47750.woho@woho.de>
	<200602270003.46353.woho@woho.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: pomac@vapor.com,
	Carl-Daniel Hailfinger <c-d.hailfinger.devel.2006@gmx.net>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Pavel Volkovitskiy <int@mtx.ru>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932328AbWB0P5Q@vger.kernel.org>
To: woho@woho.de
In-Reply-To: <200602270003.46353.woho@woho.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 27 Feb 2006 00:03:45 +0100
Wolfgang Hoffmann <woho@woho.de> wrote:

> On Sunday 26 February 2006 23:31, Wolfgang Hoffmann wrote:
> > On Sunday 26 February 2006 19:13, Wolfgang Hoffmann wrote:
> > > Ok, I did some reading and just started a git bisect. I didn't fi=
nd hints
> > > on how to bisect if I'm only interested in changes to sky2.[ch], =
so I'm
> > > taking the full kernel tree and skip testing those bisect steps t=
hat
> > > didn't change sky2.[ch].
> > >
> > > Looking at Carl-Daniels 0.13a and Stephens patch against 0.15 in =
this
> > > thread, I'll patch each bisect step such that sky2_poll() has
> > >
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0sky2_write32(hw, STAT_C=
TRL, SC_STAT_CLR_IRQ);
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (sky2_read8(hw, STAT=
_LEV_TIMER_CTRL) =3D=3D TIM_START) {
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0sky2_write8(hw, STAT_LEV_TIMER_CTRL, TIM_STOP);
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0sky2_write8(hw, STAT_LEV_TIMER_CTRL, TIM_START)=
;
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0}
> > >
> > > after exit_loop. Is that ok?
> > >
> > > I'll report as soon as I have results.
> >
> > Bisect done:
> >
> > 4d52b48b43d0d1d5959fa722ee0046e3542e5e1b is first bad commit
> >     [PATCH] sky2: support msi interrupt (revised)
> >
> > Reverting this commit in git head seems to work, at least the drive=
r builds
> > and loads. Is that sane?
> >
> > I'm currently testing this (without any further modifications), let=
's see
> > if it hangs or not.
>=20
> Ok, no hangs yet.
>=20
> This version passed a test scenario only 0.13a has survived so far. I=
'll=20
> continue to use this to give it more testing tomorrow.
>=20
> Looking at the reverted commit, I wonder if modprobing sky2 with disa=
ble_msi=3D1=20
> is equivalent to reverting the commit?
>=20

Could you try the current code with the disable_msi option?
	modprobe sky2 disable_msi=3D1

That will run existing code without MSI.
