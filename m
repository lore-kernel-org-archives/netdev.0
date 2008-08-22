From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [PATCH 1/2] Traffic control cgroups subsystem
Date: Fri, 22 Aug 2008 10:11:27 +0800
Message-ID: <48AE204F.307@cn.fujitsu.com>
References: <Pine.LNX.4.64.0808211753360.23590@ranjit.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	menage@google.com, kaber@trash.net, akpm@linux-foundation.org
To: Ranjit Manomohan <ranjitm@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55120 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753104AbYHVCM5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Aug 2008 22:12:57 -0400
In-Reply-To: <Pine.LNX.4.64.0808211753360.23590@ranjit.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static unsigned int cgroup_tc_classid(struct task_struct *tsk)
> +{
> +	unsigned int tc_classid;
> +
> +	rcu_read_lock();
> +	tc_classid =  container_of(task_subsys_state(tsk, tc_subsys_id),

trivial: 2 spaces   ^^

> +					 struct tc_cgroup, css)->classid;
> +	rcu_read_unlock();
> +	return tc_classid;
> +}
> +

...

> +static int tc_write_u64(struct cgroup *cgrp, struct cftype *cft, u64 val)
> +{
> +	struct tc_cgroup *tc = cgroup_to_tc(cgrp);
> +
> +	cgroup_lock();
> +	if (cgroup_is_removed(cgrp)) {
> +		cgroup_unlock();
> +		return -ENODEV;
> +	}
> +

You may use cgroup_lock_live_group():

	if (cgroup_lock_live_group(cgrp0))
		return -ENODEV;

> +	tc->classid = (unsigned int) (val & 0xffffffff);
> +	cgroup_unlock();
> +	return 0;
> +}
> +
> +static u64 tc_read_u64(struct cgroup *cont, struct cftype *cft)

'cont', 'cgrp' and 'cgroup' are used, it's better to make it consistent
to use 'cgrp' (or 'cgroup') only.

> +{
> +	struct tc_cgroup *tc = cgroup_to_tc(cont);
> +	return tc->classid;
> +}
