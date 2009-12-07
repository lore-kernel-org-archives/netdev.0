From: Ben Dooks <ben@fluff.org.uk>
Subject: Re: [PATCH 1/3] e1000: increase skb size to prevent dma over skb
 boundary
Date: Mon, 7 Dec 2009 15:13:26 +0000
Message-ID: <20091207151326.GB17863@fluff.org.uk>
References: <20091207144623.GA8073@hmsreliant.think-freely.org>
 <20091207144736.GB8073@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:40526 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S935228AbZLGPNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 10:13:40 -0500
Content-Disposition: inline
In-Reply-To: <20091207144736.GB8073@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 07, 2009 at 09:47:36AM -0500, Neil Horman wrote:
> Update e1000 driver to not allow dma beyond the end of the allocated skb
>     
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> 
> e1000_main.c |   34 +++++++++++++++++++++++++++++++++-
> 1 file changed, 33 insertions(+), 1 deletion(-)
> 
> 
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> index 7e855f9..7600deb 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -1667,6 +1667,19 @@ int e1000_setup_all_rx_resources(struct e1000_adapter *adapter)
>  	return err;
>  }
>  
> +static inline u32 normalize_rx_len(u32 len)
> +{
> +        u32 match, last_match;
> +
> +
> +        for (match = 0x100; match <= 0x4000; match *= 2) {
> +                if (len <= match)
> +                        return match;
> +        }
> +
> +        return 0;
> +}

thought there was an ilog2() call in the kernel to do something like
this? see linux/log2.h. will also make it easier to switch on the
result if you've got a value in bit-position instead of size.

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
