From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH] qede: fix CONFIG_INFINIBAND_QEDR=m build error
Date: Thu, 13 Oct 2016 10:44:36 +0000
Message-ID: <BL2PR07MB230634C0879011355A10B29A8DDC0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <20161012103340.978726-1-arnd@arndb.de>
 <6935319.6Adbod0g1H@wuerfel>
 <BY2PR07MB2309D9E2BEBC5A2091AC79E98DDC0@BY2PR07MB2309.namprd07.prod.outlook.com>
 <5662883.yo8OytxU65@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Ariel Elior <Ariel.Elior@qlogic.com>,
        "everest-linux-l2@qlogic.com" <everest-linux-l2@qlogic.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        "Amrani, Ram" <Ram.Amrani@cavium.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5662883.yo8OytxU65@wuerfel>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > > > While I don't mind, you could have argued is that we're not
> > > > removing enough, not too much.
> > > > I.e., perhaps the rdma_msix_* fields should also have been
> > > > ifdef-ed instead. [in which case this solution would not have
> > > > worked]
> > >
> > > That would add even more #ifdefs though.
> >
> > I agree. Although I'm never clear on the guidelines for the tradeoff -
> > How much memory/code is considered too much so that you'd have To
> > ifdef code out instead of 'wasting'?
> > [I obviously don't claim 64 bytes of memory hit that threshold]
>=20
> I don't think code size should ever be a reason for an #ifdef in a .c
> file: if the code is well-structured, you can always get the same object =
code
> using if(IS_ENABLED()) checks within the code at better readability or be=
tter
> compile-time coverage.
>=20
> Between if(IS_ENABLED()) checks and inline helpers, it usually doesn't ma=
tter
> much either way as long as the separation between the modules is clear en=
ough.
> In the example above, removing the structure fields however would require=
 to
> move the debugging output into another inline function though.

Still, the question remains - If we were to allocate X bytes of memory
per-something [in this case, per qed owned PCI function], and that memory
wouldn't be functional without a some CONFIG option enabled,
how big should X become before we'd decide the fields should also be
dependent on the option?
It bears no real relevance to this case, as the fields involved are insigni=
ficantly
small. But still - is there a rule of thumb here?

> > BTW, are you interested in doing a v2 for this? Or would you prefer if
> > we'd pick it up from here?
>=20
> I think it's better if you do a v2, as you better understand the long-ter=
m plans. I'd
> be happy to test your patch in my randconfig build setup if you like.

Sure.
