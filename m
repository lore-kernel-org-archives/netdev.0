From: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Subject: Re: hibernate event order question
Date: Sun, 18 May 2008 00:36:40 +0200
Message-ID: <20080517223622.GA2668@yamamaya.is-a-geek.org>
References: <20080517175046.GA9032@yamamaya.is-a-geek.org> <200805172156.12686.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760291AbYEQWh1@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200805172156.12686.rjw@sisk.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rafael J. Wysocki wrote:

> > Now for my question:
> > AFAICS the ordering of events is as follows:
> > 1) User reqests hibernate
> > 2) Tasks are frozen
> > 3) Device suspend callbacks get called
> > 4) Device resume callbacks get called
> > 5) Memory image is written to disk
>=20
> 6) Device suspend callbacks get called again to prepare for the syste=
m sleep
>    state.

According to my pci postcard this is not the case.
I modified nv_suspend to wiggle port 0x80 with mdelay(100) between
0xa0/0x50 wiggles and mdelay(1000) before returning, so it is easily
countable.
nv_suspend is called only once per ethernet port (step 3 above).
I have not yet tried adding a suspend_late handler.

> > In my case, I think the fix for the first bug (promiscous mode does
> > not get restored on resume) breaks wake-on-lan (since the new value
> > of NvRegPacketFilterFlags may be incompatible with wake-on-lan).

I reconfirmed this.  Without the promiscous mode bugfix,
wake-on-lan (partially) works.  With the promiscous mode bugfix the
machine doesn't wake up.  This is also easily explainable by 6) not
happening. :)

> > Shouldn't there be a 'prepare for poweroff'-callback, which gets
> > called
> > before the system is powered off for real?
>=20
> Yes, it should and it's called in recent kernels.

=46or what values of 'recent'?
I'm running 2.6.26-rc2 here. :)
How do I hook into this callback?
(suspend_late maybe? Going to try that one next...)

--=20
Tobias						PGP: http://9ac7e0bc.uguu.de
=E3=81=93=E3=81=AE=E3=83=A1=E3=83=BC=E3=83=AB=E3=81=AF=E5=8D=81=E5=89=B2=
=E5=86=8D=E5=88=A9=E7=94=A8=E3=81=95=E3=82=8C=E3=81=9F=E3=83=93=E3=83=83=
=E3=83=88=E3=81=A7=E4=BD=9C=E3=82=89=E3=82=8C=E3=81=A6=E3=81=84=E3=81=BE=
=E3=81=99=E3=80=82
