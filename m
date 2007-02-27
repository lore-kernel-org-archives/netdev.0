From: Mike Galbraith <efault@gmx.de>
Subject: Re: 2.6.21-rc1: known regressions (v2) (part 2)
Date: Tue, 27 Feb 2007 09:54:13 +0100
Message-ID: <1172566453.7009.28.camel@Homer.simpson.net>
References: <Pine.LNX.4.64.0702202043280.4043@woody.linux-foundation.org>
	 <20070226220521.GB29575@stusta.de> <1172564491.3709.5.camel@chaos>
	 <45E3ECF1.4040906@googlemail.com>  <20070227083349.GB30376@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Adrian Bunk <bunk@stusta.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David P. Reed" <dpreed@reed.com>,
	Ayaz Abdulla <aabdulla@nvidia.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org,
	Albert Hopkins <kernel@marduk.letterboxes.org>,
	Bob Tracy <rct@gherkin.frus.com>,
	Mark Brown <broonie@sirena.org.uk>,
	"Michael S. Tsirkin" <mst@mellanox.co.il>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:36991 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1161051AbXB0IyY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 03:54:24 -0500
In-Reply-To: <20070227083349.GB30376@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-02-27 at 09:33 +0100, Ingo Molnar wrote:
> * Michal Piotrowski <michal.k.k.piotrowski@gmail.com> wrote:
>=20
> > Thomas Gleixner napisa=B3(a):
> > > Adrian,
> > >=20
> > > On Mon, 2007-02-26 at 23:05 +0100, Adrian Bunk wrote:
> > >> Subject    : kernel BUG at kernel/time/tick-sched.c:168  (CONFIG=
_NO_HZ)
> > >> References : http://lkml.org/lkml/2007/2/16/346
> > >> Submitter  : Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
> > >> Handled-By : Thomas Gleixner <tglx@linutronix.de>
> > >> Status     : problem is being debugged
> > >=20
> > > The BUG_ON() was replaced by a warning printk(). The BUG_ON() exp=
osed a
> > > problem with the SMT scheduler. See below.
> > >=20
> > >> Subject    : BUG: soft lockup detected on CPU#0
> > >>              NOHZ: local_softirq_pending 20  (SMT scheduler)
> > >> References : http://lkml.org/lkml/2007/2/20/257
> > >> Submitter  : Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
> > >> Handled-By : Thomas Gleixner <tglx@linutronix.de>
> > >>              Ingo Molnar <mingo@elte.hu>
> > >> Status     : problem is being debugged
> > >=20
> > > Patch available, not confirmed yet.
> > >=20
> >=20
> > I can confirm that the bug is fixed (over 20 hours of testing shoul=
d=20
> > be enough).
>=20
> thanks alot! I think this thing was a long-term performance/latency=20
> regression in HT scheduling as well.

Agreed.

I was recently looking at that spot because I found that niced tasks
were taking latency hits, and disabled it, which helped a bunch.  I als=
o
can't understand why it would be OK to interleave a normal task with an
RT task sometimes, but not others.. that's meaningless to the RT task.

IMHO, SMT scheduling should be a buyer beware thing.  Maximizing your
core utilization comes at a price, but so does disabling it, so I think
letting the user decide what he wants is the right thing to do.

	-Mike

