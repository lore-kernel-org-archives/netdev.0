From: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 3/5] change number_of_cpusets to an atomic
Date: Tue, 24 Apr 2012 11:24:14 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1204241120130.26005@router.home>
References: <1335209867-1831-1-git-send-email-glommer@parallels.com> <1335209867-1831-4-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1204241001050.26005@router.home> <4F96D1A8.6040604@parallels.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F96D1A8.6040604-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 24 Apr 2012, Glauber Costa wrote:

> > Would this not also be a good case to introduce static branching?
> >
> > number_of_cpusets is used to avoid going through unnecessary processing
> > should there be no cpusets in use.
>
> static branches comes with a set of problems themselves, so I usually prefer
> to use them only in places where we don't want to pay even a cache miss if we
> can avoid, or a function call, or anything like that - like the slub cache
> alloc as you may have seen in my kmem memcg series.
>
> It doesn't seem to be the case here.

How did you figure that? number_of_cpusets was introduced exactly because
the functions are used in places where we do not pay the cost of calling
__cpuset_node_allowed_soft/hardwall. Have a look at these. They may take
locks etc etc in critical allocation paths
