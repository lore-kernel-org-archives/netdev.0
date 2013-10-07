From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH nf-next] netfilter: xtables: lightweight process control
 group matching
Date: Mon, 07 Oct 2013 11:07:01 +0800
Message-ID: <52522555.70407@cn.fujitsu.com>
References: <1380910855-12325-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	cgroups@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:46322 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755361Ab3JGDFz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Oct 2013 23:05:55 -0400
In-Reply-To: <1380910855-12325-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2013 02:20 AM, Daniel Borkmann wrote:
> +static void cgroup_attach(struct cgroup_subsys_state *css,
> +			  struct cgroup_taskset *tset)
> +{
> +	struct task_struct *p;
> +	void *v;
> +
> +	cgroup_taskset_for_each(p, css, tset) {
> +		task_lock(p);
> +		v = (void *)(unsigned long) task_fwid(p);

Shouldn't v be css_nf_state(css)->fwid?

> +		iterate_fd(p->files, 0, cgroup_fwid_update, v);
> +		task_unlock(p);
> +	}
> +}
