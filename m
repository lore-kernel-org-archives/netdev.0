From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] hso: fix debug routines
Date: Wed, 28 Oct 2009 16:16:17 -0700
Message-ID: <20091028161617.26a58618.akpm@linux-foundation.org>
References: <1256200578.3057.113.camel@nomovok.homedomain>
	<20091026171550.GA24910@kroah.com>
	<1256585855.3591.52.camel@nomovok.homedomain>
	<20091026194058.GA25263@kroah.com>
	<1256653615.3591.113.camel@nomovok.homedomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Jan Dumon <j.dumon@option.com>
To: Antti =?ISO-8859-1?Q?Kaijanm=E4ki?= <antti.kaijanmaki@nomovok.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755063AbZJ1XQZ@vger.kernel.org>
In-Reply-To: <1256653615.3591.113.camel@nomovok.homedomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Oct 2009 16:26:55 +0200
Antti Kaijanm=E4ki <antti.kaijanmaki@nomovok.com> wrote:

> On Mon, 2009-10-26 at 12:40 -0700, Greg KH wrote:
> > Yes, that should be a new patch, especially as it would not be need=
ed
> > to fix older kernels for the original bug.
> >=20
> > So, care to send 2 patches?  The debug one isn't needed to be sent =
to
> > the stable@kernel.org address.
>=20
>=20
> Signed-off-by: Antti Kaijanm=E4ki <antti.kaijanmaki@nomovok.com>
> ---
>  drivers/net/usb/hso.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
> index fa4e581..746839b 100644
> --- a/drivers/net/usb/hso.c
> +++ b/drivers/net/usb/hso.c
> @@ -378,7 +378,7 @@ static void dbg_dump(int line_count, const char *=
func_name, unsigned char *buf,
>  }
> =20
>  #define DUMP(buf_, len_)	\
> -	dbg_dump(__LINE__, __func__, buf_, len_)
> +	dbg_dump(__LINE__, __func__, (unsigned char *)buf_, len_)
> =20
>  #define DUMP1(buf_, len_)			\
>  	do {					\
> @@ -1527,7 +1527,7 @@ static void tiocmget_intr_callback(struct urb *=
urb)
>  		dev_warn(&usb->dev,
>  			 "hso received invalid serial state notification\n");
>  		DUMP(serial_state_notification,
> -		     sizeof(hso_serial_state_notifation))
> +		     sizeof(struct hso_serial_state_notification));
>  	} else {
> =20
>  		UART_state_bitmap =3D le16_to_cpu(serial_state_notification->

This patch has no changelog, and I'm not seeing any description of what
it fixes and how it fixes it up-thread.
