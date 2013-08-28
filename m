From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/3] Send cgroup_path in SCM_CGROUP
Date: Wed, 28 Aug 2013 10:00:00 -0400
Message-ID: <20130828140000.GB9295@htj.dyndns.org>
References: <1377614400-27122-1-git-send-email-jkaluza@redhat.com>
 <1377614400-27122-4-git-send-email-jkaluza@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, eparis@redhat.com, rgb@redhat.com
To: Jan Kaluza <jkaluza@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1377614400-27122-4-git-send-email-jkaluza@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Jan.

Can you please cc cgroup maintainers and mailing lists from
MAINTAINERS for cgroup related changes?

On Tue, Aug 27, 2013 at 04:40:00PM +0200, Jan Kaluza wrote:

Also, please describe what change is being made why on each patch.
Repeating the same description is fine but each patch descrption
should be more or less self-sufficient.

> +int scm_get_current_cgroup_path(char **cgroup_path)
> +{
> +	int ret = 0;
> +
> +	*cgroup_path = kmalloc(PAGE_SIZE, GFP_KERNEL);

PATH_MAX?

> +	if (!(*cgroup_path))
> +		return -ENOMEM;
> +
> +	ret = task_cgroup_path(current, *cgroup_path, PAGE_SIZE);
> +	if (ret < 0) {
> +		kfree(*cgroup_path);
> +		*cgroup_path = NULL;
> +	}
> +
> +	return ret;
> +}

Other than that, cgroup side looks fine to me.  For cgroup bits,

  Reviewed-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
