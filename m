From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] virtio_net: Clean up set_skb_frag()
Date: Thu, 20 Oct 2011 10:46:02 +0200
Message-ID: <1319100362.3781.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111020081727.509.83122.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rusty@rustcorp.com.au, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	virtualization@lists.linux-foundation.org
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111020081727.509.83122.sendpatchset@krkumar2.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 20 octobre 2011 =C3=A0 13:47 +0530, Krishna Kumar a =C3=A9crit=
 :
> Remove manual initialization in set_skb_frag, and instead
> use __skb_fill_page_desc() to do the same. Patch tested
> on net-next.
>=20
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
>  drivers/net/virtio_net.c |   13 +++++--------
>  1 file changed, 5 insertions(+), 8 deletions(-)
>=20
> diff -ruNp org/drivers/net/virtio_net.c new/drivers/net/virtio_net.c
> --- org/drivers/net/virtio_net.c	2011-10-20 08:34:31.000000000 +0530
> +++ new/drivers/net/virtio_net.c	2011-10-20 08:43:57.000000000 +0530
> @@ -143,18 +143,15 @@ static void skb_xmit_done(struct virtque
>  static void set_skb_frag(struct sk_buff *skb, struct page *page,
>  			 unsigned int offset, unsigned int *len)
>  {
> +	int size =3D min((unsigned)PAGE_SIZE - offset, *len);
>  	int i =3D skb_shinfo(skb)->nr_frags;
> -	skb_frag_t *f;
> =20
> -	f =3D &skb_shinfo(skb)->frags[i];
> -	skb_frag_size_set(f, min((unsigned)PAGE_SIZE - offset, *len));
> -	f->page_offset =3D offset;
> -	__skb_frag_set_page(f, page);
> +	__skb_fill_page_desc(skb, i, page, offset, size);
> =20
> -	skb->data_len +=3D skb_frag_size(f);
> -	skb->len +=3D skb_frag_size(f);
> +	skb->data_len +=3D size;
> +	skb->len +=3D size;
>  	skb_shinfo(skb)->nr_frags++;
> -	*len -=3D skb_frag_size(f);
> +	*len -=3D size;
>  }
> =20
>  static struct sk_buff *page_to_skb(struct virtnet_info *vi,
>=20
> --

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Seems fine to me. There is a truesize patch for this driver, I'll send
it once your patch is in.
