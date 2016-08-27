From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] irda: Fix likely typo in output format string
Date: Fri, 26 Aug 2016 20:23:27 -0700
Message-ID: <1472268207.26978.6.camel@perches.com>
References: <1472267646-810675-1-git-send-email-green@linuxhacker.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Oleg Drokin <green@linuxhacker.ru>,
        Samuel Ortiz <samuel@sortiz.org>,
        Chunyan Zhang <zhang.chunyan@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472267646-810675-1-git-send-email-green@linuxhacker.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(added Chunyan Zhang to cc)

On Fri, 2016-08-26 at 23:14 -0400, Oleg Drokin wrote:
> %ul would print an unsigned with a letter l at the end which does
> not seem to be desired here, on the other hand the value being printed
> is u32 so just drop the l instead of converting to %lu

Fixes: 497ec1f2a086 ("irda: vlsi_ir: Replace timeval with ktime_t")

Thanks Oleg

> diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
[]
> @@ -279,7 +279,7 @@ static void vlsi_proc_ndev(struct seq_file *seq, struct net_device *ndev)
>  		(idev->mode==IFF_SIR)?"SIR":((idev->mode==IFF_MIR)?"MIR":"FIR"));
>  	sec = div_s64_rem(ktime_us_delta(ktime_get(), idev->last_rx),
>  			  USEC_PER_SEC, &usec);
> -	seq_printf(seq, "last rx: %ul.%06u sec\n", sec, usec);
> +	seq_printf(seq, "last rx: %u.%06u sec\n", sec, usec);
>  
>  	seq_printf(seq, "RX: packets=%lu / bytes=%lu / errors=%lu / dropped=%lu",
>  		ndev->stats.rx_packets, ndev->stats.rx_bytes, ndev->stats.rx_errors,
