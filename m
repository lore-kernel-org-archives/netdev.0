From: "markus@trippelsdorf.de" <markus@trippelsdorf.de>
Subject: Re: mpd client timeouts (bisected) 2.6.35-rc3
Date: Sun, 13 Jun 2010 22:59:22 +0200
Message-ID: <20100613205922.GA1806@arch.tripp.de>
References: <20100612102802.GA1782@arch.tripp.de>
 <20100612.145835.123986343.davem@davemloft.net>
 <4C149147.3080808@intel.com>
 <4C15414E.5090201@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, alex.shi@intel.com,
	tim.c.chen@intel.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4C15414E.5090201@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 13, 2010 at 01:36:30PM -0700, John Fastabend wrote:
> John Fastabend wrote:
> >David Miller wrote:
> >>From: Markus Trippelsdorf <markus@trippelsdorf.de>
> >>Date: Sat, 12 Jun 2010 12:28:02 +0200
> >>
> >>>Commit 597a264b1a9c7e36d1728f677c66c5c1f7e3b837:
> >>>=BBnet: deliver skbs on inactive slaves to exact matches=AB
> >>>
> >>>causes large timeouts when mpd clients try to connect to a locally
> >>>running mpd (music player demon) on my machine. This makes it
> >>>impossible to control mpd.
> >>>
> >>>I bisected this down to the commit mentioned above.
> >>>Reverting the commit from 2.6.35-rc3 also solves the problem.
> >>John, find an easy and fast way to fix this or else I am
> >>going to revert.
> >>
> >>Thanks.
> >
> >Looks like skbs are hitting loopback_xmit() with deliver_no_wcard
> >set.  Then in the receive path these skbs are only delivered to
> >exact matches.  Not sure why this bit is set here, I'll track this
> >down first thing tomorrow.
> >
> >Thanks,
> >John.
> >--
>=20
> Needed to set the wcard bit in copy_skb_header otherwise it will not
> be cleared when called from skb_clone.  Which then hits the loopback
> device gets pushed into the rx path and is eventually dropped. The
> following patch fixes this. Hopefully, this is easy and fast enough
> for you Dave.
>=20
>=20
> [PATCH] net: fix deliver_no_wcard regression on loopback device

This solves the problem here. Thanks.

Tested-by: Markus Trippelsdorf <markus@trippelsdorf.de>
--=20
Markus
