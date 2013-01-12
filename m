From: Tabi Timur-B04825 <B04825@freescale.com>
Subject: Re: [net-next] gianfar: use more portable i/o accessors
Date: Sat, 12 Jan 2013 13:44:43 +0000
Message-ID: <6AE080B68D46FC4BA2D2769E68D765B70820D753@039-SN2MPN1-023.039d.mgd.msft.net>
References: <20130111161821.d62a0a60ee8d1005fb14b4d5@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Phillips Kim-R1AAHA <R1AAHA@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [65.55.88.15] ([65.55.88.15]:40075 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753292Ab3ALNqR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2013 08:46:17 -0500
In-Reply-To: <20130111161821.d62a0a60ee8d1005fb14b4d5@freescale.com>
Content-Language: en-US
Content-ID: <C48F636AB1BC07419A6C3240C2F2D502@mgd.freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 11, 2013 at 4:18 PM, Kim Phillips
<kim.phillips@freescale.com> wrote:
> in/out_be32 accessors are Power arch centric whereas
> ioread/writebe32 are available in other arches.  Also, unlike
> in/out_be32, ioread/writebe32 expect non-volatile address arguments.

I was under the impression that the "volatile" in in/out_be32() is so
that the functions can accept a volatile pointer, not that it expects
one.  Otherwise, if you pass in a volatile, you'll get a compiler
warning.

>
> Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
> ---
>  drivers/net/ethernet/freescale/gianfar.h | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
> index 1b6a67c..91bb2de 100644
> --- a/drivers/net/ethernet/freescale/gianfar.h
> +++ b/drivers/net/ethernet/freescale/gianfar.h
> @@ -1136,16 +1136,16 @@ static inline int gfar_has_errata(struct gfar_private *priv,
>         return priv->errata & err;
>  }
>
> -static inline u32 gfar_read(volatile unsigned __iomem *addr)
> +static inline u32 gfar_read(unsigned __iomem *addr)
>  {
>         u32 val;
> -       val = in_be32(addr);
> +       val = ioread32be(addr);
>         return val;
>  }

Can't we just get rid of these functions altogether?  Or at least, get
rid of the local variable?

-- 
Timur Tabi
Linux kernel developer at Freescale
