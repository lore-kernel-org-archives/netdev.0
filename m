From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH next-next-2.6 v2] virtio_net: missing sg_init_table
Date: Wed, 31 Mar 2010 12:20:22 +0300
Message-ID: <20100331092022.GA31911@redhat.com>
References: <1269887518.13277.13.camel@localhost.localdomain> <4BB10010.5060505@mathtm.de> <1269911955.14013.4.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Thomas =?iso-8859-1?Q?M=FCller?= <thomas@mathtm.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1269911955.14013.4.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 29, 2010 at 06:19:15PM -0700, Shirley Ma wrote:
> Add missing sg_init_table for sg_set_buf in virtio_net which
> induced in defer skb patch.
>=20
> Reported-by: Thomas M=FCller <thomas@mathtm.de>
> Tested-by: Thomas M=FCller <thomas@mathtm.de>
> Signed-off-by: Shirley Ma <xma@us.ibm.com>

I'm concerned that the 'big' path might cause a performance regression.
Let's move sg into virtnet_info so that this needs to be only called
once?

> ---
>  drivers/net/virtio_net.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 25dc77c..3f5be35 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -326,6 +326,7 @@ static int add_recvbuf_small(struct virtnet_info =
*vi, gfp_t gfp)
>  	struct scatterlist sg[2];
>  	int err;
> =20
> +	sg_init_table(sg, 2);
>  	skb =3D netdev_alloc_skb_ip_align(vi->dev, MAX_PACKET_LEN);
>  	if (unlikely(!skb))
>  		return -ENOMEM;
> @@ -351,6 +352,7 @@ static int add_recvbuf_big(struct virtnet_info *v=
i, gfp_t gfp)
>  	char *p;
>  	int i, err, offset;
> =20
> +	sg_init_table(sg, MAX_SKB_FRAGS + 2);
>  	/* page in sg[MAX_SKB_FRAGS + 1] is list tail */
>  	for (i =3D MAX_SKB_FRAGS + 1; i > 1; --i) {
>  		first =3D get_a_page(vi, gfp);
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
