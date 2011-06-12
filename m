From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH] drivers/ssb/driver_chipcommon_pmu.c: uninitilized
 warning
Date: Sun, 12 Jun 2011 11:07:21 +0200
Message-ID: <20110612090721.GA9247@liondog.tnic>
References: <1307816085-20062-1-git-send-email-cmdkhh@gmail.com>
 <20110611205057.4b9bf462@maggie>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael =?utf-8?B?QsO8c2No?= <m@bues.ch>, mb@bu3sch.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Connor Hansen <cmdkhh@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110611205057.4b9bf462@maggie>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 11, 2011 at 08:50:57PM +0200, Michael B=C3=BCsch wrote:
> On Sat, 11 Jun 2011 11:14:45 -0700
> Connor Hansen <cmdkhh@gmail.com> wrote:
>=20
> > warning message
> > drivers/ssb/driver_chipcommon_pmu.c: In function ssb_pmu_resources_=
init
> > drivers/ssb/driver_chipcommon_pmu.c:420:15: warning: updown_tab_siz=
e may
> > be used uninitilized in this function.
> >=20
> > updown_tab_size and depend_tab_size may not be set in the bus->chip=
_id
> > switch statement, so set to 0 by default to avoid using uninitializ=
ed
> > stack space.
>=20
> We wouldn't be using uninitialized stack space or uninitialized varia=
bles,
> without this patch. However, for the sake of shutting up the compiler=
, ACK.

Also, Connor you have to be more specific in your commit messages.
Especially if this warning is triggered only with the extended build
checks aka make W=3D[123].

Please take a look at the code and check whether this is actually
fixing anything first because Michael is correct - there's no case
where {depend,uptown}_tab_size will be used uninitialized. So having
unnecessary churn when the compiler bitches about something it can't
understand yet is not something we want.

Thanks.

>=20
> > Signed-off-by: Connor Hansen <cmdkhh@gmail.com>
> > ---
> >  drivers/ssb/driver_chipcommon_pmu.c |    4 ++--
> >  1 files changed, 2 insertions(+), 2 deletions(-)
> >=20
> > diff --git a/drivers/ssb/driver_chipcommon_pmu.c b/drivers/ssb/driv=
er_chipcommon_pmu.c
> > index 305ade7..a7aef47 100644
> > --- a/drivers/ssb/driver_chipcommon_pmu.c
> > +++ b/drivers/ssb/driver_chipcommon_pmu.c
> > @@ -417,9 +417,9 @@ static void ssb_pmu_resources_init(struct ssb_c=
hipcommon *cc)
> >  	u32 min_msk =3D 0, max_msk =3D 0;
> >  	unsigned int i;
> >  	const struct pmu_res_updown_tab_entry *updown_tab =3D NULL;
> > -	unsigned int updown_tab_size;
> > +	unsigned int updown_tab_size =3D 0;
> >  	const struct pmu_res_depend_tab_entry *depend_tab =3D NULL;
> > -	unsigned int depend_tab_size;
> > +	unsigned int depend_tab_size =3D 0;
> > =20
> >  	switch (bus->chip_id) {
> >  	case 0x4312:
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--=20
Regards/Gruss,
    Boris.
