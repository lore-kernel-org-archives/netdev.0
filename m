From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH -next 1/4] cgroup: Add cgroup_get_from_fd
Date: Wed, 22 Jun 2016 11:35:07 -0400
Message-ID: <20160622153507.GW3262@mtj.duckdns.org>
References: <1466555002-1316296-1-git-send-email-kafai@fb.com>
 <1466555002-1316296-2-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
	Daniel Borkmann <daniel@iogearbox.net>, kernel-team@fb.com
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1466555002-1316296-2-git-send-email-kafai@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Martin.

On Tue, Jun 21, 2016 at 05:23:19PM -0700, Martin KaFai Lau wrote:
> @@ -6205,6 +6206,31 @@ struct cgroup *cgroup_get_from_path(const char *path)
>  }
>  EXPORT_SYMBOL_GPL(cgroup_get_from_path);

Proper function comment would be nice.

> +struct cgroup *cgroup_get_from_fd(int fd)
> +{
> +	struct cgroup_subsys_state *css;
> +	struct cgroup *cgrp;
> +	struct file *f;
> +
> +	f = fget_raw(fd);
> +	if (!f)
> +		return NULL;

It returns NULL here.

> +	css = css_tryget_online_from_dir(f->f_path.dentry, NULL);
> +	fput(f);
> +	if (IS_ERR(css))
> +		return ERR_CAST(css);
> +
> +	cgrp = css->cgroup;
> +	if (!cgroup_on_dfl(cgrp)) {
> +		cgroup_put(cgrp);
> +		return ERR_PTR(-EINVAL);

But an ERR_PTR value here.  Is this intentional?  Also, wouldn't it
make more sense to return -EBADF here, given that that's what
css_tryget_online_from_dir() would return if the filesystem type is
wrong?

Thanks!

-- 
tejun
