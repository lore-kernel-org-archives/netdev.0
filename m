From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net_dbg_ratelimited: turn into no-op when !DEBUG
Date: Tue, 04 Aug 2015 08:51:05 -0700
Message-ID: <1438703465.10829.20.camel@perches.com>
References: <20150803.215900.915316341182067498.davem@davemloft.net>
	 <1438700836-6715-1-git-send-email-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438700836-6715-1-git-send-email-Jason@zx2c4.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-08-04 at 17:07 +0200, Jason A. Donenfeld wrote:
> The pr_debug family of functions turns into a no-op when -DDEBUG is not
> specified, opting instead to call "no_printk", which gets compiled to a
> no-op (but retains gcc's nice warnings about printf-style arguments).
[]
> diff --git a/include/linux/net.h b/include/linux/net.h
[]
> @@ -239,8 +239,14 @@ do {								\
>  	net_ratelimited_function(pr_warn, fmt, ##__VA_ARGS__)
>  #define net_info_ratelimited(fmt, ...)				\
>  	net_ratelimited_function(pr_info, fmt, ##__VA_ARGS__)
> +#if defined(DEBUG)
>  #define net_dbg_ratelimited(fmt, ...)				\
>  	net_ratelimited_function(pr_debug, fmt, ##__VA_ARGS__)
> +#else
> +#define net_dbg_ratelimited(fmt, ...)				\
> +	if (0)							\
> +		no_printk(KERN_DEBUG pr_fmt(fmt), ##__VA_ARGS__)
> +#endif

This should be:

#define net_dbg_ratelimited(fmt, ...)				\
do {								\
	if (0)							\
		no_printk(KERN_DEBUG pr_fmt(fmt), ##__VA_ARGS__); \
} while (0)

to be safe in if/else uses
