From: Wolfgang Hoffmann <woho@woho.de>
Subject: Re: [PATCH] Revert sky2 to 0.13a
Date: Mon, 27 Feb 2006 00:03:45 +0100
Message-ID: <200602270003.46353.woho@woho.de>
References: <4400FC28.1060705@gmx.net> <200602261913.36308.woho@woho.de> <200602262331.47750.woho@woho.de>
Reply-To: woho@woho.de
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: pomac@vapor.com,
	Carl-Daniel Hailfinger <c-d.hailfinger.devel.2006@gmx.net>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Pavel Volkovitskiy <int@mtx.ru>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751022AbWBZXCY@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <200602262331.47750.woho@woho.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 26 February 2006 23:31, Wolfgang Hoffmann wrote:
> On Sunday 26 February 2006 19:13, Wolfgang Hoffmann wrote:
> > Ok, I did some reading and just started a git bisect. I didn't find=
 hints
> > on how to bisect if I'm only interested in changes to sky2.[ch], so=
 I'm
> > taking the full kernel tree and skip testing those bisect steps tha=
t
> > didn't change sky2.[ch].
> >
> > Looking at Carl-Daniels 0.13a and Stephens patch against 0.15 in th=
is
> > thread, I'll patch each bisect step such that sky2_poll() has
> >
> > =A0=A0=A0=A0=A0=A0=A0sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
> > =A0=A0=A0=A0=A0=A0=A0if (sky2_read8(hw, STAT_LEV_TIMER_CTRL) =3D=3D=
 TIM_START) {
> > =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0sky2_write8(hw, STAT_L=
EV_TIMER_CTRL, TIM_STOP);
> > =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0sky2_write8(hw, STAT_L=
EV_TIMER_CTRL, TIM_START);
> > =A0=A0=A0=A0=A0=A0=A0=A0}
> >
> > after exit_loop. Is that ok?
> >
> > I'll report as soon as I have results.
>
> Bisect done:
>
> 4d52b48b43d0d1d5959fa722ee0046e3542e5e1b is first bad commit
>     [PATCH] sky2: support msi interrupt (revised)
>
> Reverting this commit in git head seems to work, at least the driver =
builds
> and loads. Is that sane?
>
> I'm currently testing this (without any further modifications), let's=
 see
> if it hangs or not.

Ok, no hangs yet.

This version passed a test scenario only 0.13a has survived so far. I'l=
l=20
continue to use this to give it more testing tomorrow.

Looking at the reverted commit, I wonder if modprobing sky2 with disabl=
e_msi=3D1=20
is equivalent to reverting the commit?
