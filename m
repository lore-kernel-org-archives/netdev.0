From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: RFC: struct netdevice changes for IPoIB UC
	support
Date: Wed, 21 Sep 2005 18:15:23 +1000
Message-ID: <E1EHzlD-0004eE-00@gondolin.me.apana.org.au>
References: <20050921080230.GE18449@mellanox.co.il>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	openib-general@openib.org, linux-kernel@vger.kernel.org
Return-path: <openib-general-bounces@openib.org>
To: "Michael S. Tsirkin" <mst@mellanox.co.il>
In-Reply-To: <20050921080230.GE18449@mellanox.co.il>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

Michael S. Tsirkin <mst@mellanox.co.il> wrote:
> 
> Please comment on this approach: does it make sense to you guys?
> Please Cc me directly, I'm not on the list.

Sorry, this doesn't make sense.  
 
> static inline u32 dst_mtu(const struct dst_entry *dst)
> {
> -       u32 mtu = dst_metric(dst, RTAX_MTU);
> +       u32 mtu;
> +       if (dst->dev && dst->dev->get_mtu)
> +               mtu = dst->dev->get_mtu(dst->dev, dst->neighbour,
> +                                       dst_metric(dst, RTAX_MTU));
> +       else
> +               mtu = dst_metric(dst, RTAX_MTU);

>From this I gather that for a given dst the MTU is actually constant.
That is, it only varies across different dst's.

In this case you should calculate the correct MTU when the dst is
created rather than here.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
