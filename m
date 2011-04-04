From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: Re: [PATCH] X86:NET:Replaced a deprecated function .
Date: Mon, 4 Apr 2011 11:36:20 +0200
Message-ID: <20110404093620.GA4896@isilmar-3.linta.de>
References: <1301909548-20031-1-git-send-email-wanlong.gao@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, padovan@profusion.mobi, joe@perches.com,
	marcel@holtmann.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: wanlong.gao@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1301909548-20031-1-git-send-email-wanlong.gao@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, Apr 04, 2011 at 05:32:28PM +0800, wanlong.gao@gmail.com wrote:
> From: Wanlong Gao <wanlong.gao@gmail.com>
> 
> kernel_warning: pcmcia_request_exclusive_irq is deprecated .

NACK. This papers over the issue, instead of fixing it. To properly fix it,
one needs to verify that the IRQ handler used in this driver is capable of
handling a shared IRQ line.

Best,
	Dominik

> Signed-off-by: Wanlong Gao <wanlong.gao@gmail.com>
> ---
>  drivers/net/pcmcia/nmclan_cs.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
> index 76683d9..bf97231
> --- a/drivers/net/pcmcia/nmclan_cs.c
> +++ b/drivers/net/pcmcia/nmclan_cs.c
> @@ -625,7 +625,7 @@ static int nmclan_config(struct pcmcia_device *link)
>    ret = pcmcia_request_io(link);
>    if (ret)
>  	  goto failed;
> -  ret = pcmcia_request_exclusive_irq(link, mace_interrupt);
> +  ret = __pcmcia_request_exclusive_irq(link, mace_interrupt);
>    if (ret)
>  	  goto failed;
>    ret = pcmcia_enable_device(link);
> -- 
> 1.7.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
