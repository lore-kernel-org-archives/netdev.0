From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: clear heap allocation for ETHTOOL_GRXCLSRLALL
Date: Thu, 07 Oct 2010 21:28:58 +0100
Message-ID: <1286483338.2271.34.camel@achroite.uk.solarflarecom.com>
References: <20101007200348.GA6038@outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org
To: Kees Cook <kees.cook@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101007200348.GA6038@outflux.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-10-07 at 13:03 -0700, Kees Cook wrote:
> Calling ETHTOOL_GRXCLSRLALL with a large rule_cnt will allocate kernel
> heap without clearing it. For the one driver (niu) that implements it,
> it will leave the unused portion of heap unchanged and copy the full
> contents back to userspace.
> 
> Cc: stable@kernel.org
> Signed-off-by: Kees Cook <kees.cook@canonical.com>

Acked-by: Ben Hutchings <bhutchings@solarflare.com>

Should have spotted this myself. :-(

Ben.

> ---
>  net/core/ethtool.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index 7a85367..4016ac6 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -348,7 +348,7 @@ static noinline_for_stack int ethtool_get_rxnfc(struct net_device *dev,
>  	if (info.cmd == ETHTOOL_GRXCLSRLALL) {
>  		if (info.rule_cnt > 0) {
>  			if (info.rule_cnt <= KMALLOC_MAX_SIZE / sizeof(u32))
> -				rule_buf = kmalloc(info.rule_cnt * sizeof(u32),
> +				rule_buf = kzalloc(info.rule_cnt * sizeof(u32),
>  						   GFP_USER);
>  			if (!rule_buf)
>  				return -ENOMEM;
> -- 
> 1.7.1
> 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
