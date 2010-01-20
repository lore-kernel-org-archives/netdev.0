From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] sfc: EFX_ETHTOOL_STAT calculates the offset of the
 efx##source_name's field in both cases
Date: Wed, 20 Jan 2010 03:12:19 +0000
Message-ID: <1263957139.6090.3.camel@localhost>
References: <4B56659E.3040001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Steve Hodgson <shodgson@solarflare.com>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754471Ab0ATDMb@vger.kernel.org>
In-Reply-To: <4B56659E.3040001@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-01-20 at 03:08 +0100, Roel Kluin wrote:
> EFX_ETHTOOL_STAT calculated the offset of the efx##source_name's field
> Regardless of whether that field was NULL.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> This looks like a bug, but I am not sure whether I understood this correctly,
> nor was it tested, was this intended?

The condition is really a type check.  The result should be the same
regardless of whether it is true.

Ben.

> diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
> index 6c0bbed..722bac7 100644
> --- a/drivers/net/sfc/ethtool.c
> +++ b/drivers/net/sfc/ethtool.c
> @@ -41,7 +41,7 @@ struct efx_ethtool_stat {
>  	.source = EFX_ETHTOOL_STAT_SOURCE_##source_name,		\
>  	.offset = ((((field_type *) 0) ==				\
>  		      &((struct efx_##source_name *)0)->field) ?	\
> -		    offsetof(struct efx_##source_name, field) :		\
> +		    offsetof(struct efx_##stat_name, field) :		\
>  		    offsetof(struct efx_##source_name, field)),		\
>  	.get_stat = get_stat_function,					\
>  }

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
