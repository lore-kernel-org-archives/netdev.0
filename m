From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 5/6] ath6kl: convert ath6kl_dbg() and ath6kl_dbg_dump()
 into functions
Date: Wed, 04 Jan 2012 15:41:12 -0800
Message-ID: <1325720472.4116.7.camel@joe2Laptop>
References: <20120104230429.32306.75965.stgit@x201>
	 <20120104230950.32306.21264.stgit@x201>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-next@vger.kernel.org,
	ath6kl-devel@qualcomm.com, davem@davemloft.net
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120104230950.32306.21264.stgit@x201>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-01-05 at 01:09 +0200, Kalle Valo wrote:
> That way it's possible to not export debug_mask outside the upcoming
> ath6kl_core.ko and that makes it easier to ath6kl_core.ko in the
> following patch.
[]
> Signed-off-by: Kalle Valo <kvalo@qca.qualcomm.com>
[]
> diff --git a/drivers/net/wireless/ath/ath6kl/debug.c b/drivers/net/wireless/ath/ath6kl/debug.c
[]
> +void ath6kl_dbg(enum ATH6K_DEBUG_MASK mask, const char *fmt, ...)
> +{
> +	va_list args;
> +
> +	if (!(debug_mask & mask))
> +		return;
> +
> +	va_start(args, fmt);
> +	ath6kl_printk(KERN_DEBUG, fmt, &args);

Passing a va_list as an argument?
I believe this doesn't work.
I think you'll need to add and use:

	struct va_format vaf;

	vaf.fmt = fmt;
	vaf.va = &args;

	ath6kl_printk(KERN_DEBUG, "%pV", &vaf);
