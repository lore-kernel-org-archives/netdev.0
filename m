From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH nf-next] netfilter: xtables: lightweight process control
 group matching
Date: Wed, 9 Oct 2013 13:04:09 -0400
Message-ID: <20131009170409.GH22495@htj.dyndns.org>
References: <1380910855-12325-1-git-send-email-dborkman@redhat.com>
 <20131007164647.GA2481@htj.dyndns.org>
 <5253BCAE.5060409@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5253BCAE.5060409-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

On Tue, Oct 08, 2013 at 10:05:02AM +0200, Daniel Borkmann wrote:
> Could you elaborate on "Wouldn't it be more logical to implement netfilter
> rule to match the target cgroup paths?". I don't think (or hope) you mean
> some string comparison on the dentry path here? :) With our proposal, we
> have in the network stack's critical path only the following code that is
> being executed here to match the cgroup ...

Comparing path each time obviously doesn't make sense but you can
determine the cgroup on config and hold onto the pointer while the
rule exists.

> ... where ``info->id == skb->sk->sk_cgrp_fwid'' is the actual work, so very
> lightweight, which is good for high loads (1Gbit/s, 10Gbit/s and beyond), of
> course. Also, it would be intuitive for admins familiar with other subsystems
> to just set up and use these cgroup ids in iptabels. I'm not yet quite sure
> how your suggestion would look like, so you would need to setup some "dummy"
> subgroups first just to have a path that you can match on?

Currently, it's tricky because we have multiple hierarchies to
consider and there isn't an efficient way to map from task to cgroup
on a specific hierarchy.  I'm not sure whether we should add another
mapping table in css_set or just allow using path matching on the
unified hierarchy.  The latter should be cleaner and easier but more
restrictive.

Anyways, it isn't manageable in the long term to keep adding
controllers simply to tag tasks differently.  If we want to do this,
let's please work on a way to match a task's cgroup affiliation
efficiently.

Thanks.

-- 
tejun
