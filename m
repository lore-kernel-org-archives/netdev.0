From: Ivo Van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH] rt2x00: Use kcalloc instead of kzalloc to allocate array
Date: Sat, 3 Dec 2011 12:46:15 +0100
Message-ID: <CAOZOX0UU7Jcd1XbV-bM4OBCwwySNyVOwQ_u2yhwyigfUgx=eBA@mail.gmail.com>
References: <1322600880.1534.325.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: gwingerde@gmail.com, helmut.schaa@googlemail.com,
	linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	users@rt2x00.serialmonkey.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Thomas Meyer <thomas@m3y3r.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1322600880.1534.325.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 29, 2011 at 10:08 PM, Thomas Meyer <thomas@m3y3r.de> wrote:
> The advantage of kcalloc is, that will prevent integer overflows whic=
h could
> result from the multiplication of number of elements and size and it =
is also
> a bit nicer to read.
>
> The semantic patch that makes this change is available
> in https://lkml.org/lkml/2011/11/25/107
>
> Signed-off-by: Thomas Meyer <thomas@m3y3r.de>

Acked-by: Ivo van Doorn <IvDoorn@gmail.com>

> ---
>
> diff -u -p a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wi=
reless/rt2x00/rt2x00dev.c
> --- a/drivers/net/wireless/rt2x00/rt2x00dev.c 2011-11-28 19:36:47.770=
108588 +0100
> +++ b/drivers/net/wireless/rt2x00/rt2x00dev.c 2011-11-28 19:54:53.495=
525543 +0100
> @@ -831,11 +831,11 @@ static int rt2x00lib_probe_hw_modes(stru
> =A0 =A0 =A0 =A0if (spec->supported_rates & SUPPORT_RATE_OFDM)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0num_rates +=3D 8;
>
> - =A0 =A0 =A0 channels =3D kzalloc(sizeof(*channels) * spec->num_chan=
nels, GFP_KERNEL);
> + =A0 =A0 =A0 channels =3D kcalloc(spec->num_channels, sizeof(*channe=
ls), GFP_KERNEL);
> =A0 =A0 =A0 =A0if (!channels)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
>
> - =A0 =A0 =A0 rates =3D kzalloc(sizeof(*rates) * num_rates, GFP_KERNE=
L);
> + =A0 =A0 =A0 rates =3D kcalloc(num_rates, sizeof(*rates), GFP_KERNEL=
);
> =A0 =A0 =A0 =A0if (!rates)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto exit_free_channels;
>
