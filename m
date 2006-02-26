From: Wolfgang Hoffmann <woho@woho.de>
Subject: Re: [PATCH] Revert sky2 to 0.13a
Date: Sun, 26 Feb 2006 19:13:36 +0100
Message-ID: <200602261913.36308.woho@woho.de>
References: <4400FC28.1060705@gmx.net> <200602260957.04305.woho@woho.de> <1140966011.22812.2.camel@localhost>
Reply-To: woho@woho.de
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Carl-Daniel Hailfinger <c-d.hailfinger.devel.2006@gmx.net>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Pavel Volkovitskiy <int@mtx.ru>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751385AbWBZSMW@vger.kernel.org>
To: pomac@vapor.com
In-Reply-To: <1140966011.22812.2.camel@localhost>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 26 February 2006 16:00, Ian Kumlien wrote:
> On Sun, 2006-02-26 at 09:57 +0100, Wolfgang Hoffmann wrote:
> > Stephen, if you want me (as suggested off-list) to bisect the indiv=
idual
> > patches leading from 0.13a to current head, please give me a series=
 of
> > patches to incrementally apply, eighter via mail/ftp/git, and I'll =
test.
> > I don't want to hack the patches together myself, because results w=
ould
> > be worthless if I screw up, and given that I have no networking
> > background chances are high ...
>
> There is a git bisect for that, and a link for it somewhere =3D)

Ok, I did some reading and just started a git bisect. I didn't find hin=
ts on=20
how to bisect if I'm only interested in changes to sky2.[ch], so I'm ta=
king=20
the full kernel tree and skip testing those bisect steps that didn't ch=
ange=20
sky2.[ch].

Looking at Carl-Danies 0.13a and Stephens patch against 0.15 in this th=
read,=20
I'll patch each bisect step such that sky2_poll() has

=A0=A0=A0=A0=A0=A0=A0sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
=A0=A0=A0=A0=A0=A0=A0if (sky2_read8(hw, STAT_LEV_TIMER_CTRL) =3D=3D TIM=
_START) {
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0sky2_write8(hw, STAT_LEV_T=
IMER_CTRL, TIM_STOP);
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0sky2_write8(hw, STAT_LEV_T=
IMER_CTRL, TIM_START);
=A0=A0=A0=A0=A0=A0=A0=A0}

after exit_loop. Is that ok?

I'll report as soon as I have results.
