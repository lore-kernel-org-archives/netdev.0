From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 3/6] net: ethernet: ti: cpts: add support of cpts
 HW_TS_PUSH
Date: Wed, 30 Nov 2016 11:19:03 +0100
Message-ID: <20161130101903.GE28680@localhost.localdomain>
References: <20161128230428.6872-1-grygorii.strashko@ti.com>
 <20161128230428.6872-4-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
        Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>,
        Wingman Kwok <w-kwok2-l0cyMroinI0@public.gmane.org>
To: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161128230428.6872-4-grygorii.strashko-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 28, 2016 at 05:04:25PM -0600, Grygorii Strashko wrote:
> +/* HW TS */
> +static int cpts_extts_enable(struct cpts *cpts, u32 index, int on)
> +{
> +	unsigned long flags;
> +	u32 v;
> +
> +	if (index >= cpts->info.n_ext_ts)
> +		return -ENXIO;
> +
> +	if (((cpts->hw_ts_enable & BIT(index)) >> index) == on)
> +		return 0;
> +
> +	spin_lock_irqsave(&cpts->lock, flags);
> +
> +	v = cpts_read32(cpts, control);
> +	if (on) {
> +		v |= BIT(8 + index);
> +		cpts->hw_ts_enable |= BIT(index);
> +	} else {
> +		v &= ~BIT(8 + index);
> +		cpts->hw_ts_enable &= ~BIT(index);
> +	}
> +	cpts_write32(cpts, v, control);
> +
> +	spin_unlock_irqrestore(&cpts->lock, flags);
> +
> +	if (cpts->hw_ts_enable)
> +		/* poll for events faster - evry 200 ms */

every

> +		cpts->ov_check_period =
> +			msecs_to_jiffies(CPTS_EVENT_HWSTAMP_TIMEOUT);

Bad indentation.  Use braces {} to contain the comment and assignment
statement.

> +	else
> +		cpts->ov_check_period = cpts->ov_check_period_slow;
> +
> +	mod_delayed_work(system_wq, &cpts->overflow_work,
> +			 cpts->ov_check_period);
> +
> +	return 0;
> +}

Thanks,
Richard
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
