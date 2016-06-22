From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] mellanox: mlx5: Use logging functions to reduce text
 ~10k/5%
Date: Wed, 22 Jun 2016 15:20:43 -0700
Message-ID: <1466634043.13093.15.camel@perches.com>
References: <1466619839.13093.4.camel@perches.com>
	 <20160622204056.GB20838@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160622204056.GB20838-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-06-22 at 14:40 -0600, Jason Gunthorpe wrote:
> On Wed, Jun 22, 2016 at 11:23:59AM -0700, Joe Perches wrote:
> > The output changes now do not include line #, but do include the
> > function offset.
> I've been using a technique like this in some code with good results:
>=20
> struct source_location
> {
> =A0=A0=A0const char *file;
> =A0=A0=A0const char *func;
> =A0=A0=A0const char *format;
> =A0=A0=A0uint16_t line;
> };
> #define _LOCATION(format) ({static const source_location __location__
> =3D {\
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0__FILE__,__PRETTY_FUNCTION__,f=
ormat,__LINE__};\
> 	=A0=A0=A0=A0=A0&__location__;})
>=20
> void _mlx5_core_err(const struct source_location *loc,struct
> mlx5_core_dev *dev, ...);
> #define mlx5_core_err(dev,format,...)
> _mlx_core_err(_LOCATION(format),dev,__VA_ARGS__)
>=20
> The call site .text overhead is the about same as what you have, but
> this still retains the function and line number information in
> .rodata.

Hello Jason.

As far as I know, no kernel code currently uses a _LOCATION
like macro.

I think your proposal is nearly identical code size to the
existing call. =A0Also, compiler format/argument checking is
eliminated and I think that is a significant negative.

Using the kernel vsprintf %pS or %ps extension is pretty common.

Using printk("%pS", __builtin_return_address(0)); in the called
function is no overhead at all and returns almost exactly
the same information.

Using more expressive messages is generally better than using
printk("%d", __LINE__);

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
