From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH net-next 2/2] drivers/net: Remove casts of void *
Date: Tue, 14 Jun 2011 16:02:30 +0200
Message-ID: <BANLkTi=VfxOqg6N_=B7wYaa4Qm8erVuBHg@mail.gmail.com>
References: <cover.1308024069.git.joe@perches.com>
	<486a21b708a9dce0c1c0059a21a2f9b66dac9e3c.1308024069.git.joe@perches.com>
	<BANLkTim-yLJqfxrCprwiTgdRJNy+OGDUuw@mail.gmail.com>
	<1308060028.18987.6.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>,
	Divy Le Ray <divy@chelsio.com>,
	Breno Leitao <leitao@linux.vnet.ibm.com>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>,
	Ron Mercer <ron.mercer@qlogic.com>, linux-driver@qlogic.com,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	Jon Mason <jdmason@kudzu.us>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Steve Hodgson <shodgson@solarflare.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Daniele Venzano <venza@brownhat
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1308060028.18987.6.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe,

On Tue, Jun 14, 2011 at 16:00, Joe Perches <joe@perches.com> wrote:
> On Tue, 2011-06-14 at 11:21 +0200, Geert Uytterhoeven wrote:
>> On Tue, Jun 14, 2011 at 06:02, Joe Perches <joe@perches.com> wrote:
>> > Unnecessary casts of void * clutter the code.
>> > --- a/drivers/net/a2065.c
>> > +++ b/drivers/net/a2065.c
>> > @@ -426,7 +426,7 @@ static irqreturn_t lance_interrupt (int irq, v=
oid *dev_id)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0volatile struct lance_regs *ll;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0int csr0;
>> >
>> > - =C2=A0 =C2=A0 =C2=A0 dev =3D (struct net_device *) dev_id;
>> > + =C2=A0 =C2=A0 =C2=A0 dev =3D dev_id;
>>
>> I think it would look better if you merge this line with the line th=
at
>> defines "dev".
>
> I think so too, but I also think it should look like below
> and that's something better done in a separate pass, don't
> you think?
>
> diff --git a/drivers/net/a2065.c b/drivers/net/a2065.c
> index deaa8bc..25ea98a 100644
> --- a/drivers/net/a2065.c
> +++ b/drivers/net/a2065.c
> @@ -421,16 +421,11 @@ static int lance_tx (struct net_device *dev)
>
> =C2=A0static irqreturn_t lance_interrupt (int irq, void *dev_id)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 struct net_device *dev;
> - =C2=A0 =C2=A0 =C2=A0 struct lance_private *lp;
> - =C2=A0 =C2=A0 =C2=A0 volatile struct lance_regs *ll;
> + =C2=A0 =C2=A0 =C2=A0 struct net_device *dev =3D dev_id;
> + =C2=A0 =C2=A0 =C2=A0 struct lance_private *lp =3D netdev_priv(dev);
> + =C2=A0 =C2=A0 =C2=A0 volatile struct lance_regs *ll =3D lp->ll;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int csr0;
>
> - =C2=A0 =C2=A0 =C2=A0 dev =3D (struct net_device *) dev_id;
> -
> - =C2=A0 =C2=A0 =C2=A0 lp =3D netdev_priv(dev);
> - =C2=A0 =C2=A0 =C2=A0 ll =3D lp->ll;
> -
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ll->rap =3D LE_CSR0; =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0/* LANCE Controller Status */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0csr0 =3D ll->rdp;

Definitely better!

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds
