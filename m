From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] sunrpc: prompt for RPCSEC_GSS_KRB5 even if NFS_V4 is
	enabled
Date: Mon, 27 Sep 2010 14:54:04 +0200
Message-ID: <20100927125404.GB6271@pengutronix.de>
References: <20100909181454.GB14915@pengutronix.de> <1285584120-16860-1-git-send-email-u.kleine-koenig@pengutronix.de> <1285587572.19362.2.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	"David S. Miller" <davem@davemloft.net>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1285587572.19362.2.camel@heimdal.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Trond,

On Mon, Sep 27, 2010 at 07:39:32AM -0400, Trond Myklebust wrote:
> On Mon, 2010-09-27 at 12:41 +0200, Uwe Kleine-K=F6nig wrote:
> > NFS_V4 works fine without RPCSEC_GSS_KRB5 (even without CRYPTO).
> > This dependency was introduced in
> >=20
> > 	df486a2 (NFS: Fix the selection of security flavours in Kconfig)
> >=20
> > to fix a build failure as RPCSEC_GSS_KRB5 was thought to be needed =
for
> > NFS_V4.  The fix didn't work completely as NFS_V4 didn't enforce CR=
YPTO
> > and so the select on RPCSEC_GSS_KRB5 didn't work in all situations =
(e.g.
> > arm/mx1_defconfig).
> >=20
> > This was rectified by
> >=20
> > 	827e345 (SUNRPC: Fix the NFSv4 and RPCSEC_GSS Kconfig dependencies=
)
> >=20
> > but the magic for RPCSEC_GSS_KRB5 introduced by df486a2 wasn't reve=
rted.
> >=20
> > Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
> > Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> > ---
> > Hello,
> >=20
> > after Trond sent me the patch that later ended in 827e345702 I sugg=
ested
> > to fold the patch below into it[1], but without reaction and succes=
s as I
> > noticed just now. :-(
> >=20
> > Best regards
> > Uwe
>=20
> That's because you completely fail to justify why should we change th=
e
> behaviour to suddenly make RPCSEC_GSS_KRB5 optional for NFSv4. That h=
as
> never been the case before.
My intention is not to make "RPCSEC_GSS_KRB5 optional for NFSv4".  Firs=
t
I saw a build failure and then I wondered if the fix was optimal.  Afte=
r
reading the log of 827e345 I thought NFSv4 doesn't depend on
RPCSEC_GSS_KRB5, still more considering that 827e345 was your fix after
I suggested to select CRYPTO to enforce RPCSEC_GSS_KRB5 again.

Currently you can have NFSv4 without RPCSEC_GSS_KRB5 because if you
don't have CRYPTO RPCSEC_GSS_KRB5 is off, too, even if it defaults to
yes and there's no prompt.  (Selecting would not work, too.)
And note that RPCSEC_GSS_KRB5 already selects SUNRPC_GSS, so 827e345
doesn't do anything useful if NFS_V4 really needs RPCSEC_GSS_KRB5.

So either we should really enforce RPCSEC_GSS_KRB5 if NFS_V4 is selecte=
d
(by letting one of these select CRYPTO, see e.g. my first patch, or by
letting NFS_V4 depend on CRYPTO) or make it optional in all cases (as i=
t
is already now in some cases).

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
