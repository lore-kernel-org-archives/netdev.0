From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] e100: expose broadcast_disabled as a module option
Date: Fri, 23 Apr 2010 13:58:16 -0700
Message-ID: <20100423135816.23f5861f@nehalam>
References: <l2nb43bf5491004231314i13503c67yeccfc54bc1cae850@mail.gmail.com>
	<h2p9929d2391004231322r23528f32z8447a711a29e28ea@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Erwan Velu <erwanaliasr1@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, alexander.h.duyck@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <h2p9929d2391004231322r23528f32z8447a711a29e28ea@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 23 Apr 2010 13:22:22 -0700
Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

> On Fri, Apr 23, 2010 at 13:14, Erwan Velu <erwanaliasr1@gmail.com> wr=
ote:
> > Hi folks,
> >
> > I've been facing a very noisy network where hundreds broadcast pack=
ets
> > were generated every second.
> > When this traffic can't be controlled at the source, there is a sid=
e
> > effect on some systems.
> > I was having some idle systems that will never be targeted by this
> > broadcast traffic that got loaded just by receiving that "flood".
> > I mean by loaded that this light hardware was generating 300
> > context/switches per second.
> >
> > I was looking for many options to avoid this traffic to disturb thi=
s
> > hosts and I discovered that the e100 driver was featuring a
> > "broadcast_disabled" configure option.
> > I realize that this option is not controllable, so I wrote this sim=
ple
> > patch that expose this option as a module option.
> > This allow me to tell this hosts not to listen anymore this traffic=
=2E
> >
> > The result is clearly good as my systems are now running at 21
> > context/switches while being idle.
> > Hope this patch isn't too bad and could help others that faces the =
same problem.
> >
> > Patch can be downloaded here :
> > http://konilope.linuxeries.org/e100_broadcast_disabled.patch
> >
> > Even if gmail is eating the inlined, patch, at least that make it
> > easier to read it for humans.
> > If the patch is acked, the downloaded one will be more clean ;)
> >
> > This patch was generated on top of the latest 2.6 torvald's git.
> > Cheers,
> > Erwan
> >
> > Signed-off-by: Erwan Velu <erwanaliasr1@gmail.com>
> >
> > diff --git a/drivers/net/e100.c b/drivers/net/e100.c
> > index b997e57..2ba582f 100644
> > --- a/drivers/net/e100.c
> > +++ b/drivers/net/e100.c
> > @@ -194,12 +194,15 @@ MODULE_FIRMWARE(FIRMWARE_D102E);
> > =C2=A0static int debug =3D 3;
> > =C2=A0static int eeprom_bad_csum_allow =3D 0;
> > =C2=A0static int use_io =3D 0;
> > +static int broadcast_disabled =3D 0;
> > =C2=A0module_param(debug, int, 0);
> > =C2=A0module_param(eeprom_bad_csum_allow, int, 0);
> > =C2=A0module_param(use_io, int, 0);
> > +module_param(broadcast_disabled, int, 0);
> > =C2=A0MODULE_PARM_DESC(debug, "Debug level (0=3Dnone,...,16=3Dall)"=
);
> > =C2=A0MODULE_PARM_DESC(eeprom_bad_csum_allow, "Allow bad eeprom che=
cksums");
> > =C2=A0MODULE_PARM_DESC(use_io, "Force use of i/o access mode");
> > +MODULE_PARM_DESC(broadcast_disabled, "Filter broadcast packets
> > (0=3Ddisabled (default), 1=3Denabled)");
> > =C2=A0#define DPRINTK(nlevel, klevel, fmt, args...) \
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0(void)((NETIF_MSG_##nlevel & nic->msg_en=
able) && \
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0printk(KERN_##klevel PFX "%s: %s: " fmt,=
 nic->netdev->name, \
> > @@ -1131,6 +1134,8 @@ static void e100_configure(struct nic *nic,
> > struct cb *cb, struct sk_buff *skb)
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0config->prom=
iscuous_mode =3D 0x1; =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* 1=3Don, 0=3Doff */
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> >
> > + =C2=A0 =C2=A0 =C2=A0 config->broadcast_disabled =3D broadcast_dis=
abled; /* Broadcast filtering */
> > +
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (nic->flags & multicast_all)
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0config->mult=
icast_all =3D 0x1; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* 1=3Dacce=
pt, 0=3Dno */
> > --
>=20
> Adding Netdev...
>=20

What is wrong with using existing IFF_BROADCAST flag?


--=20
