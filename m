From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [RFC PATCH] bgmac: Fix build error seen if BCM47XX is not
 configured
Date: Wed, 15 Apr 2015 13:46:35 -0700
Message-ID: <20150415204635.GA18364@roeck-us.net>
References: <1429128338-28549-1-git-send-email-linux@roeck-us.net>
 <CACna6rwPYP0FV60v9ey0uV=3eU_8SZ4t+WoZCtiDHHeCLiM3Dg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ralf Baechle <ralf@linux-mips.org>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"linux-mips@linux-mips.org" <linux-mips@linux-mips.org>
To: =?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACna6rwPYP0FV60v9ey0uV=3eU_8SZ4t+WoZCtiDHHeCLiM3Dg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 15, 2015 at 10:21:49PM +0200, Rafa=C5=82 Mi=C5=82ecki wrote=
:
> On 15 April 2015 at 22:05, Guenter Roeck <linux@roeck-us.net> wrote:
> > arm:allmodconfig fails to build as follows since ARCH_BCM_5301X
> > is configured but not BCM47XX.
> >
> > drivers/net/ethernet/broadcom/bgmac.c: In function 'bgmac_probe':
> > drivers/net/ethernet/broadcom/bgmac.c:1643:2: error:
> >                 implicit declaration of function 'bcm47xx_nvram_get=
env'
> >
> > Fixes: fc300dc3733f ("bgmac: allow enabling on ARCH_BCM_5301X")
> > Cc: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
> > Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> > ---
> > Seen in today's upstream kernel.
> >
> > I don't like this fix too much (I think it is quite kludgy),
> > so I marked it RFC (and please don't beat the messenger ;-).
>=20
> Ooh great, I totally forgot about this :|
>=20
> The problem is that fc300dc (bgmac: allow enabling on ARCH_BCM_5301X)
> [0] shouldn't really be sent (by me) in the first place. This is
> because it depends on 138173d (MIPS: BCM47xx: Move NVRAM header to th=
e
> include/linux/.) [1] which isn't in Linus's tree yet.
>=20
> So there are two solutions:
> 1) Revert fc300dc, wait for 138173d and re-apply fc300dc
> 2) Wait for 138173d with this build breakage
>=20
> I guess the decisions depends on
> a) time needed for David to revert fc300dc & send pull request
> vs.
> b) time needed for Ralf to send pull request
>=20
> David, Ralf, what do you think about this?
>=20

Since the fix is in the queue, maybe we can live with the breakage
for a few days ? Your solution is definitely _much_ better than my hack=
=2E

Guenter
