From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH nf-next] netfilter: xtables: lightweight process control
 group matching
Date: Mon, 07 Oct 2013 11:17:50 +0200
Message-ID: <52527C3E.1060004@redhat.com>
References: <1380910855-12325-1-git-send-email-dborkman@redhat.com> <52522555.70407@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	cgroups@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <52522555.70407@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/07/2013 05:07 AM, Gao feng wrote:
> On 10/05/2013 02:20 AM, Daniel Borkmann wrote:
>> +static void cgroup_attach(struct cgroup_subsys_state *css,
>> +			  struct cgroup_taskset *tset)
>> +{
>> +	struct task_struct *p;
>> +	void *v;
>> +
>> +	cgroup_taskset_for_each(p, css, tset) {
>> +		task_lock(p);
>> +		v = (void *)(unsigned long) task_fwid(p);
>
> Shouldn't v be css_nf_state(css)->fwid?

Nope, this is in line with net_cls and net_prio; the task has been
moved there via cgroup backend already through cgroup_attach_task(),
so we only need to update each of it's socket sk_cgrp_fwid parts.
css is not strictly for net_filter. See also: 6a328d8c6f (cgroup:
net_cls: Rework update socket logic)

>> +		iterate_fd(p->files, 0, cgroup_fwid_update, v);
>> +		task_unlock(p);
>> +	}
>> +}
