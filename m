From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] aoe: mark AoE packets as requiring no checksumming
Date: Thu, 20 Sep 2012 02:25:03 +0100
Message-ID: <1348104303.4836.63.camel@deadeye.wl.decadent.org.uk>
References: <1348079358.4585@cat.he.net>
	 <cover.1348088283.git.ecashin@coraid.com>
	 <72368962c6414543ce7d2c3f1ab5f36154fdd710.1348088283.git.ecashin@coraid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <akpm@linux-foundation.org>,
	<jesse@nicira.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Ed Cashin <ecashin@coraid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <72368962c6414543ce7d2c3f1ab5f36154fdd710.1348088283.git.ecashin@coraid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-09-19 at 18:17 -0700, Ed Cashin wrote:
> In order for the network layer to see that AoE requires
> no checksumming in a generic way, packets should be marked
> CHECKSUM_NONE.

Which they are by default.

> Rather than relying on the current behavior of alloc_skb,
> this change causes the aoe driver to explicitly mark its
> packets as requiring no checksum.
>
> Signed-off-by: Ed Cashin <ecashin@coraid.com>
> ---
>  drivers/block/aoe/aoecmd.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/block/aoe/aoecmd.c b/drivers/block/aoe/aoecmd.c
> index de0435e..0ba1b63 100644
> --- a/drivers/block/aoe/aoecmd.c
> +++ b/drivers/block/aoe/aoecmd.c
> @@ -35,6 +35,7 @@ new_skb(ulong len)
>  		skb_reset_mac_header(skb);
>  		skb_reset_network_header(skb);
>  		skb->protocol = __constant_htons(ETH_P_AOE);
> +		skb->ip_summed = CHECKSUM_NONE;

Can be written as:
		skb_checksum_none_assert(skb);
if you really want to be sure.

Ben.

>  	}
>  	return skb;
>  }

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
