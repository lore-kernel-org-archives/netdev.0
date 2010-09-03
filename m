From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/2] posix clocks: introduce a syscall for clock tuning.
Date: Fri, 3 Sep 2010 11:58:32 +0200
Message-ID: <20100903095832.GA22138@riccoc20.at.omicron.at>
References: <cover.1283504065.git.richard.cochran@omicron.at>
 <7f4815cdfcf5bc49df4bdd09d59a4f56ca2598f5.1283504065.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <7f4815cdfcf5bc49df4bdd09d59a4f56ca2598f5.1283504065.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 03, 2010 at 11:29:05AM +0200, Richard Cochran wrote:
> +long compat_sys_clock_adjtime(clockid_t which_clock,
> +		struct compat_timex __user *utp)
> +{
> +	struct timex txc;
> +	mm_segment_t oldfs;
> +	int err, ret;
> +
> +	err = compat_get_timex(&txc, utp);
> +	if (err)
> +		return err;
> +
> +	oldfs = get_fs();
> +	set_fs(KERNEL_DS);
> +	ret = sys_clock_adjtime(which_clock, (struct timex __user *) &txc);
> +	set_fs(oldfs);

I don't know what the purpose of get_fs, set_fs is, but the other
clock_ functions have it that way. The adjtimex call does not have
this at all, so I ask, do we need this here, or not?

Thanks,
Richard
