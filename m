From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH] net: pxa168_eth: avoid using signed char for bitops
Date: Fri, 3 Oct 2014 17:07:03 +0200
Message-ID: <20141003150703.GA20398@kwain>
References: <1412348517-20352-1-git-send-email-antoine.tenart@free-electrons.com>
 <1412348517-20352-2-git-send-email-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
	sebastian.hesselbarth@gmail.com,
	alexandre.belloni@free-electrons.com,
	thomas.petazzoni@free-electrons.com, zmxu@marvell.com,
	jszhang@marvell.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1412348517-20352-2-git-send-email-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 03, 2014 at 05:01:54PM +0200, Antoine Tenart wrote:
> Signedness bugs may occur when using signed char for bitops,
> depending on if the highest bit is ever used.
>=20
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
>=20
> Dan reported a static checker warning:
> http://marc.info/?l=3Dkernel-janitors&m=3D141218246222535&w=3D2
>=20
> This patch fixes it. Instead of using sa->sa_data we now use
> dev->dev_addr (of type unsigned char *) to avoid possible
> signedness issues.

Well, this patch shouldn't be in this thread. I'm resending it.
Sorry for the noise.

Antoine

>=20
>  drivers/net/ethernet/marvell/pxa168_eth.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/=
ethernet/marvell/pxa168_eth.c
> index 24de41231593..c3b209cd0660 100644
> --- a/drivers/net/ethernet/marvell/pxa168_eth.c
> +++ b/drivers/net/ethernet/marvell/pxa168_eth.c
> @@ -634,12 +634,12 @@ static int pxa168_eth_set_mac_address(struct ne=
t_device *dev, void *addr)
>  	memcpy(oldMac, dev->dev_addr, ETH_ALEN);
>  	memcpy(dev->dev_addr, sa->sa_data, ETH_ALEN);
> =20
> -	mac_h =3D sa->sa_data[0] << 24;
> -	mac_h |=3D sa->sa_data[1] << 16;
> -	mac_h |=3D sa->sa_data[2] << 8;
> -	mac_h |=3D sa->sa_data[3];
> -	mac_l =3D sa->sa_data[4] << 8;
> -	mac_l |=3D sa->sa_data[5];
> +	mac_h =3D dev->dev_addr[0] << 24;
> +	mac_h |=3D dev->dev_addr[1] << 16;
> +	mac_h |=3D dev->dev_addr[2] << 8;
> +	mac_h |=3D dev->dev_addr[3];
> +	mac_l =3D dev->dev_addr[4] << 8;
> +	mac_l |=3D dev->dev_addr[5];
>  	wrl(pep, MAC_ADDR_HIGH, mac_h);
>  	wrl(pep, MAC_ADDR_LOW, mac_l);
> =20
> --=20
> 1.9.1
>=20

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
