From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [PATCH v3 08/10] ARM: mxs: add ocotp read function
Date: Wed, 5 Jan 2011 17:56:17 +0000
Message-ID: <20110105175617.GD12222@shareable.org>
References: <1294236457-17476-1-git-send-email-shawn.guo@freescale.com>
	<1294236457-17476-9-git-send-email-shawn.guo@freescale.com>
	<20110105161235.GA2112@gallagher>
	<20110105164409.GV25121@pengutronix.de>
	<20110105172501.GB2112@gallagher>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: gerg@snapgear.com, B32542@freescale.com, netdev@vger.kernel.org,
	s.hauer@pengutronix.de, bryan.wu@canonical.com,
	baruch@tkos.co.il, w.sang@pengutronix.de, r64343@freescale.com,
	Shawn Guo <shawn.guo@freescale.com>, eric@eukrea.com,
	Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	lw@karo-electronics.de
To: Jamie Iles <jamie@jamieiles.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20110105172501.GB2112@gallagher>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Jamie Iles wrote:
> On Wed, Jan 05, 2011 at 05:44:09PM +0100, Uwe Kleine-K=F6nig wrote:
> > Hello Jamie,
> > On Wed, Jan 05, 2011 at 04:16:46PM +0000, Jamie Iles wrote:
> > > On Wed, Jan 05, 2011 at 10:07:35PM +0800, Shawn Guo wrote:
> > > > +	/* check both BUSY and ERROR cleared */
> > > > +	while ((__raw_readl(ocotp_base) &
> > > > +		(BM_OCOTP_CTRL_BUSY | BM_OCOTP_CTRL_ERROR)) && --timeout)
> > > > +		/* nothing */;
> > > =

> > > Is it worth using cpu_relax() in these polling loops?
> > I don't know what cpu_relax does for other platforms, but on ARM it's
> > just a memory barrier which AFAICT doesn't help here at all (which
> > doesn't need to be correct).  Why do you think it would be better?
> =

> Well I don't see that there's anything broken without cpu_relax() but =

> using cpu_relax() seems to be the most common way of doing busy polling =

> loops that I've seen. It's also a bit easier to read than a comment and =

> semi-colon. Perhaps it's just personal preference.

cpu_relax() is a hint to the CPU to, for example, save power or be
less aggressive on the memory bus (to save power or be fairer).

Currently these architectures do more than just a barrier in cpu_relax():
x86, IA64, PowerPC, Tile and S390.

Although it's just a hint on ARM at the moment, it might change in
future - especially with power mattering on so many ARM systems.
(Even now, just changing it to a very short udelay might save power
on existing ARMs without breaking drivers.)


By the way, I see ARM defines cpu_relax as smp_mb() on arch >=3D 6.  Is
that correct and useful?  On other architectures*, barrier() is enough
of a barrier, but it's conceivable that smp_mb() would have some
ARM-specific fairness or bus activity benefit - in which case it
should probably be mb().

* - except Blackfin, which historically derived a lot from ARM headers.

-- Jamie
