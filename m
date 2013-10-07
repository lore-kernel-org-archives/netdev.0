From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH nf-next] netfilter: xtables: lightweight process control
 group matching
Date: Mon, 07 Oct 2013 17:42:49 +0800
Message-ID: <52528219.6000002@cn.fujitsu.com>
References: <1380910855-12325-1-git-send-email-dborkman@redhat.com> <52522555.70407@cn.fujitsu.com> <52527C3E.1060004@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <52527C3E.1060004-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/07/2013 05:17 PM, Daniel Borkmann wrote:
> On 10/07/2013 05:07 AM, Gao feng wrote:
>> On 10/05/2013 02:20 AM, Daniel Borkmann wrote:
>>> +static void cgroup_attach(struct cgroup_subsys_state *css,
>>> +              struct cgroup_taskset *tset)
>>> +{
>>> +    struct task_struct *p;
>>> +    void *v;
>>> +
>>> +    cgroup_taskset_for_each(p, css, tset) {
>>> +        task_lock(p);
>>> +        v = (void *)(unsigned long) task_fwid(p);
>>
>> Shouldn't v be css_nf_state(css)->fwid?
> 
> Nope, this is in line with net_cls and net_prio; the task has been
> moved there via cgroup backend already through cgroup_attach_task(),

Yes, these tasks have already been migrated to this cgroup.

> so we only need to update each of it's socket sk_cgrp_fwid parts.

Sorry, I still don't know in which situation that css_nf_state(css)->fwid
isn't equal to task_fwid(p).

two threads write the same pid to different cgroup at the same time?
it seems can not happen since we have cgroup_mutex protected.

> css is not strictly for net_filter. See also: 6a328d8c6f (cgroup:
> net_cls: Rework update socket logic)
> 
>>> +        iterate_fd(p->files, 0, cgroup_fwid_update, v);
>>> +        task_unlock(p);
>>> +    }
>>> +}
> 
