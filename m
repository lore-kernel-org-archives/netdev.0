From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH nf-next] netfilter: xtables: lightweight process control group matching
Date: Fri, 18 Oct 2013 16:21:55 -0700
Message-ID: <87li1qp3l8.fsf@xmission.com>
References: <1380910855-12325-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1380910855-12325-1-git-send-email-dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (Daniel
	Borkmann's message of "Fri, 4 Oct 2013 20:20:55 +0200")
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> Implementation of PID-based matching would not be appropriate
> as they frequently change, and child tracking would make that
> even more complex and ugly. Cgroups would be a perfect candidate
> for accomplishing that as they associate a set of tasks with a
> set of parameters for one or more subsystems, in our case the
> netfilter subsystem, which, of course, can be combined with other
> cgroup subsystems into something more complex.

I am coming to this late.  But two concrete suggestions.

1) process groups and sessions don't change as frequently as pids.

2) It is possible to put a set of processes in their own network
   namespace and pipe just the packets you want those processes to
   use into that network namespace.  Using an ingress queueing filter
   makes that process very efficient even if you have to filter by port.

So I don't think you need cgroups to solve this problem at all.

Eric
