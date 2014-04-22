From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] netprio_cgroup: explicitly init the early_init field
Date: Tue, 22 Apr 2014 07:19:06 -0400
Message-ID: <20140422111906.GD17116@hmsreliant.think-freely.org>
References: <1398144722-9864-1-git-send-email-nasa4836@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, lizefan@huawei.com, tj@kernel.org,
	daniel.wagner@bmw-carit.de, gaofeng@cn.fujitsu.com,
	stephen@networkplumber.org, jiri@resnulli.us,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jianyu Zhan <nasa4836@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1398144722-9864-1-git-send-email-nasa4836@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 22, 2014 at 01:32:02PM +0800, Jianyu Zhan wrote:
> For a cgroup subsystem who should init early, then it should carefully
> take care of the implementation of css_alloc, because it will be called
> before mm_init() setup the world.
> 
> Luckily we don't, and we better explicitly assign the early_init field
> to 0, for document reason.
> 
> Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
> ---
>  net/core/netprio_cgroup.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
> index 13ddd68..fc21035 100644
> --- a/net/core/netprio_cgroup.c
> +++ b/net/core/netprio_cgroup.c
> @@ -250,6 +250,7 @@ struct cgroup_subsys net_prio_cgrp_subsys = {
>  	.css_free	= cgrp_css_free,
>  	.attach		= net_prio_attach,
>  	.base_cftypes	= ss_files,
> +	.early_init	= 0,
>  };
>  
>  static int netprio_device_event(struct notifier_block *unused,
> -- 
> 2.0.0-rc0
> 
> 
NACK, for the same reason that it doesn't make sense for net_classid.
Early_init should already be zero.  What problem are you trying to solve here?

Neil
