From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH 22/22] IB/mlx4: fix sprintf format warning
Date: Fri, 14 Jul 2017 16:48:54 +0300
Message-ID: <20170714134854.GA1528@mtr-leonro.local>
References: <20170714120720.906842-1-arnd@arndb.de>
 <20170714120720.906842-23-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="YQq6ULGNIN0mNoNa"
Cc: linux-kernel@vger.kernel.org, Yishai Hadas <yishaih@mellanox.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Guenter Roeck <linux@roeck-us.net>, akpm@linux-foundation.org,
        netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        "James E . J . Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K . Petersen" <martin.petersen@oracle.com>,
        linux-scsi@vger.kernel.org, x86@kernel.org,
        Adit Ranadive <aditr@vmware.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Steve Wise <swise@opengridcomputing.com>,
        linux-rdma@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170714120720.906842-23-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--YQq6ULGNIN0mNoNa
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Jul 14, 2017 at 02:07:14PM +0200, Arnd Bergmann wrote:
> gcc-7 points out that a negative port_num value would overflow
> the string buffer:
>
> drivers/infiniband/hw/mlx4/sysfs.c: In function 'mlx4_ib_device_register_sysfs':
> drivers/infiniband/hw/mlx4/sysfs.c:251:16: error: 'sprintf' may write a terminating nul past the end of the destination [-Werror=format-overflow=]
> drivers/infiniband/hw/mlx4/sysfs.c:251:2: note: 'sprintf' output between 2 and 11 bytes into a destination of size 10
> drivers/infiniband/hw/mlx4/sysfs.c:303:17: error: 'sprintf' may write a terminating nul past the end of the destination [-Werror=format-overflow=]
> drivers/infiniband/hw/mlx4/sysfs.c:303:3: note: 'sprintf' output between 2 and 11 bytes into a destination of size 10
>
> While we should be able to assume that port_num is positive here,
> making the buffer one byte longer has no downsides and avoids the
> warning.
>
> Fixes: c1e7e466120b ("IB/mlx4: Add iov directory in sysfs under the ib device")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/infiniband/hw/mlx4/sysfs.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>

Thanks,
Reviewed-by: Leon Romanovsky <leonro@mellanox.com>

--YQq6ULGNIN0mNoNa
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlloy8YACgkQ5GN7iDZy
WKfQhhAAuuX8K3VxBgM6ss+NLx4OcWE2xF0yzYQqzZazEIj3LIGJfW/uwfJp3jIb
Mh/zh1ohmPkVl62DFoz4cGGgis/LsgSMzjCaZhUUr5YCIUMZv8aPcXiLiTbzvBwe
byv9/FvU8CYT+6WOTmPaPmZuhazewxpDNuoR+sMAetn7LHjxnmupAhBgUMIkwmSx
U0ndSg63H4LgjEpcToWUuKflY+J8afyfU5bSw1TIXLyv5r5CQQhC0hF5nuDGW7yz
6mb7lfmIGSz3JittojJGnnuu9ocOH2hJKZfL9Hk6W1ayP0PV/t6rrMmehv0DT4F0
QT0vVwrLop2xQd1GL6LwlQ+An1KAVb930JyakqPgW7qO6hoCoEIVY5mLCIUSYsW7
NVR5n4F9eSMtXOzuNBJPz/BanHRmGpB25WbcYOlk5oujSDy4TigtbAnE4VV+CEwS
6fJOKkkB8jb0IRRStFgqDyo+AsBuI0i72NQlQGOfW6GEWCaUvkVj5iXirqDClSVL
Noig1sAPUpfMGy6gmP5i5NNx3hRZ5DImCAlstPPuyGznRCOuqqisDqeFEa9b4J70
IkaaxDPki9IqOXPC0mEwsSPzKHZG7F+l58MXuTiiu1lb5abxlxrtVUpeoA1R4dkI
+YFu04ToeenpDQD87FuB809V2bG5HlTBcGdFjwk8uVG+CwxjR0U=
=8V7p
-----END PGP SIGNATURE-----

--YQq6ULGNIN0mNoNa--
