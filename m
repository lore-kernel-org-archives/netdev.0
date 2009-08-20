From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: zorro8390: Fix read buffer overflow in zorro8390_init_one()
Date: Thu, 20 Aug 2009 13:53:51 +0200
Message-ID: <10f740e80908200453p726acd5bpac49068f0492249a@mail.gmail.com>
References: <200908182159.n7ILxX3d013229@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-m68k@lists.linux-m68k.org
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754118AbZHTLxv@vger.kernel.org>
In-Reply-To: <200908182159.n7ILxX3d013229@hera.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 18, 2009 at 23:59, Linux Kernel Mailing
List<linux-kernel@vger.kernel.org> wrote:
> Gitweb: =C2=A0 =C2=A0 http://git.kernel.org/linus/be12159b24c532b4b48=
bdec5a543336438faa132
> Commit: =C2=A0 =C2=A0 be12159b24c532b4b48bdec5a543336438faa132
> Parent: =C2=A0 =C2=A0 5e33b719c8fcccfedc1d25167826a0f93fe6c5a1
> Author: =C2=A0 =C2=A0 roel kluin <roel.kluin@gmail.com>
> AuthorDate: Sun Aug 9 04:00:25 2009 +0000
> Committer: =C2=A0David S. Miller <davem@davemloft.net>
> CommitDate: Sun Aug 9 21:46:53 2009 -0700
>
> =C2=A0 =C2=A0zorro8390: Fix read buffer overflow in zorro8390_init_on=
e()
>
> =C2=A0 =C2=A0Prevent read from cards[-1] when no card was found.
>
> =C2=A0 =C2=A0Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> =C2=A0 =C2=A0Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
> =C2=A0drivers/net/zorro8390.c | =C2=A0 =C2=A03 +++
> =C2=A01 files changed, 3 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/zorro8390.c b/drivers/net/zorro8390.c
> index 37c84e3..81c753a 100644
> --- a/drivers/net/zorro8390.c
> +++ b/drivers/net/zorro8390.c
> @@ -120,6 +120,9 @@ static int __devinit zorro8390_init_one(struct zo=
rro_dev *z,
> =C2=A0 =C2=A0 for (i =3D ARRAY_SIZE(cards)-1; i >=3D 0; i--)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (z->id =3D=3D cards[i].id)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0break;
> + =C2=A0 =C2=A0if (i < 0)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0return -ENODEV;
> +
> =C2=A0 =C2=A0 board =3D z->resource.start;
> =C2=A0 =C2=A0 ioaddr =3D board+cards[i].offset;
> =C2=A0 =C2=A0 dev =3D alloc_ei_netdev();

That case can never happen, as zorro8390_init_one() won't be called
without a matching ID.

But probably the information in struct card_info should be stored in
zorro8390_zorro_tbl[].driver_data,
so we can remove cards[] and the look up.

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
							    -- Linus Torvalds
