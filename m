From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 1/4] ath: Add and use ath_printk and ath_<level>
Date: Tue, 7 Dec 2010 16:38:58 -0500
Message-ID: <20101207213857.GN2700@tuxdriver.com>
References: <cover.1291333543.git.joe@perches.com>
 <241e75c84fdd26bfae1c7b8806fe64fbac5de627.1291333544.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <lrodriguez@atheros.com>,
	linux-kernel@vger.kernel.org, Peter Stuge <peter@stuge.se>,
	Felix Fietkau <nbd@openwrt.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <241e75c84fdd26bfae1c7b8806fe64fbac5de627.1291333544.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 02, 2010 at 07:12:35PM -0800, Joe Perches wrote:
> Add ath_printk and ath_<level> similar to
> dev_printk and dev_<level> from device.h
> 
> This allows a more gradual rename of ath_print
> to to ath_dbg or perhaps ath_debug.
> 
> This basically removes debug.h leaving
> only an #define ath_printk ath_dbg
> there and moving all the ATH_DBG_<foo>
> enums to ath.h
> 
> I do not think there's much purpose for struct
> ath_common * being passed to the ath_printk
> functions, but perhaps there might be.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

> +#define ATH_DBG_WARN(foo, arg...) WARN(foo, arg)
> +
> +#else
> +
> +static inline  __attribute__ ((format (printf, 3, 4))) int
> +ath_dbg(struct ath_common *common, enum ATH_DEBUG dbg_mask,
> +	const char *fmt, ...)
> +{
> +	return 0;
> +}
> +#define ATH_DBG_WARN(foo, arg) do {} while (0)

Missing the "..." after "arg" -- I fixed it up...

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
