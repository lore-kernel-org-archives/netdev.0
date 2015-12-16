From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 02/15] i40iw: add main, hdr, status
Date: Wed, 16 Dec 2015 12:31:13 -0800
Message-ID: <1450297873.24782.7.camel@perches.com>
References: <1450295919-17292-1-git-send-email-faisal.latif@intel.com>
	 <1450295919-17292-2-git-send-email-faisal.latif@intel.com>
	 <1450295919-17292-3-git-send-email-faisal.latif@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, e1000-rdma-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1450295919-17292-3-git-send-email-faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-12-16 at 13:58 -0600, Faisal Latif wrote:
> i40iw_main.c contains routines for i40e <=> i40iw interface and setup.
> i40iw.h is header file for main device data structures.
> i40iw_status.h is for return status codes.
[]
> diff --git a/drivers/infiniband/hw/i40iw/i40iw.h b/drivers/infiniband/hw/i40iw/i40iw.h
[]
> +#define i40iw_pr_err(fmt, args ...) pr_err("%s: error " fmt, __func__, ## args)
> +
> +#define i40iw_pr_info(fmt, args ...) pr_info("%s: " fmt, __func__, ## args)
> +
> +#define i40iw_pr_warn(fmt, args ...) pr_warn("%s: " fmt, __func__, ## args)

Using "error " in the output doesn't really add much
as there's already a KERN_ERR with the output.

Using __func__ hardly adds anything.

Using netdev_<level> is generally preferred

> +
> +struct i40iw_cqp_request {
> +	struct cqp_commands_info info;
> +	wait_queue_head_t waitq;
> +	struct list_head list;
> +	atomic_t refcount;
> +	void (*callback_fcn)(struct i40iw_cqp_request*, u32);
> +	void *param;
> +	struct i40iw_cqp_compl_info compl_info;
> +	u8 waiting:1;
> +	u8 request_done:1;
> +	u8 dynamic:1;
> +	u8 polling:1;

These would bitfields might be better as bool

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
