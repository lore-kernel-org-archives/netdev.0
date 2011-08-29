From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 2/2] ath: Make ath_printk void not int and remove unused
 struct ath_common *
Date: Mon, 29 Aug 2011 14:12:38 -0400
Message-ID: <20110829181237.GB1406@tuxdriver.com>
References: <cover.1314347556.git.joe@perches.com>
 <78869fcd8172cd02266b66a71aadbd0c0efbdebc.1314347556.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <lrodriguez@atheros.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <78869fcd8172cd02266b66a71aadbd0c0efbdebc.1314347556.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 26, 2011 at 01:56:39AM -0700, Joe Perches wrote:
> Changing the return type and removing the unused argument from
> ath_printk reduces code size.
> 
> Add an __always_unused struct ath_common * to the macros
> that call ath_printk to avoid unused variable warnings.
> 
> $ size drivers/net/wireless/ath/built-in.o*
>    text	   data	    bss	    dec	    hex	filename
> 1159859	  16235	 212000	1388094	 152e3e	drivers/net/wireless/ath/built-in.o.new
> 1164175	  16235	 212032	1392442	 153f3a	drivers/net/wireless/ath/built-in.o.old
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/wireless/ath/ath.h  |   27 ++++++++++++++++-----------
>  drivers/net/wireless/ath/main.c |    8 ++------
>  2 files changed, 18 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/net/wireless/ath/ath.h b/drivers/net/wireless/ath/ath.h
> index a3f8505..9891fb6 100644
> --- a/drivers/net/wireless/ath/ath.h
> +++ b/drivers/net/wireless/ath/ath.h
> @@ -178,24 +178,29 @@ bool ath_hw_keyreset(struct ath_common *common, u16 entry);
>  void ath_hw_cycle_counters_update(struct ath_common *common);
>  int32_t ath_hw_get_listen_time(struct ath_common *common);
>  
> -extern __attribute__((format (printf, 3, 4)))
> -int ath_printk(const char *level, struct ath_common *common,
> -	       const char *fmt, ...);
> +extern __attribute__((format (printf, 2, 3)))
> +void ath_printk(const char *level, const char *fmt, ...);
> +
> +#define _ath_printk(level, common, fmt, ...)			\
> +do {								\
> +	__always_unused struct ath_common *unused = common;	\
> +	ath_printk(level, fmt, ##__VA_ARGS__);			\
> +} while (0)
>  
>  #define ath_emerg(common, fmt, ...)				\
> -	ath_printk(KERN_EMERG, common, fmt, ##__VA_ARGS__)
> +	_ath_printk(KERN_EMERG, common, fmt, ##__VA_ARGS__)
>  #define ath_alert(common, fmt, ...)				\
> -	ath_printk(KERN_ALERT, common, fmt, ##__VA_ARGS__)
> +	_ath_printk(KERN_ALERT, common, fmt, ##__VA_ARGS__)
>  #define ath_crit(common, fmt, ...)				\
> -	ath_printk(KERN_CRIT, common, fmt, ##__VA_ARGS__)
> +	_ath_printk(KERN_CRIT, common, fmt, ##__VA_ARGS__)
>  #define ath_err(common, fmt, ...)				\
> -	ath_printk(KERN_ERR, common, fmt, ##__VA_ARGS__)
> +	_ath_printk(KERN_ERR, common, fmt, ##__VA_ARGS__)
>  #define ath_warn(common, fmt, ...)				\
> -	ath_printk(KERN_WARNING, common, fmt, ##__VA_ARGS__)
> +	_ath_printk(KERN_WARNING, common, fmt, ##__VA_ARGS__)
>  #define ath_notice(common, fmt, ...)				\
> -	ath_printk(KERN_NOTICE, common, fmt, ##__VA_ARGS__)
> +	_ath_printk(KERN_NOTICE, common, fmt, ##__VA_ARGS__)
>  #define ath_info(common, fmt, ...)				\
> -	ath_printk(KERN_INFO, common, fmt, ##__VA_ARGS__)
> +	_ath_printk(KERN_INFO, common, fmt, ##__VA_ARGS__)
>  
>  /**
>   * enum ath_debug_level - atheros wireless debug level

Any reason to preserve all these "common" args?

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
