From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] printk: Warn about dropped messages also on extended
 consoles
Date: Thu, 30 Jul 2015 09:39:01 -0400
Message-ID: <20150730133901.GC3504@mtj.duckdns.org>
References: <1438255732-31326-1-git-send-email-pmladek@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Petr Mladek <pmladek@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1438255732-31326-1-git-send-email-pmladek@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Thu, Jul 30, 2015 at 01:28:52PM +0200, Petr Mladek wrote:
> The commit #6fe29354befe4c ("printk: implement support for extended console
> drivers") added an extra buffer to format messages for extended consoles.
> We need to put there also the warning about dropped messages, so it appears
> on these consoles.

I don't get it.  Extended messages are all stamped with sequence
number and the gap in sequence number is a clear sign of missing
messages.

> diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
> index cf8c24203368..77d3d3698283 100644
> --- a/kernel/printk/printk.c
> +++ b/kernel/printk/printk.c
> @@ -2254,8 +2254,15 @@ again:
>  		}
>  
>  		if (console_seq < log_first_seq) {
> -			len = sprintf(text, "** %u printk messages dropped ** ",
> -				      (unsigned)(log_first_seq - console_seq));
> +			static const char dropped_msg[] =
> +				"** %u printk messages dropped ** ";
> +			unsigned int dropped_count =
> +				(unsigned int)(log_first_seq - console_seq);
> +
> +			len = sprintf(text, dropped_msg, dropped_count);
> +			if (nr_ext_console_drivers)
> +				ext_len = sprintf(ext_text, dropped_msg,
> +						  dropped_count);

And you can't shove random message in front of the header.

Nacked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
