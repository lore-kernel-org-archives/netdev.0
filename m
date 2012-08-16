From: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH v0 0/5] cgroup: Assign subsystem IDs during compile time
Date: Thu, 16 Aug 2012 15:05:42 -0400
Message-ID: <20120816190542.GA8203@hmsreliant.think-freely.org>
References: <1345126336-20755-1-git-send-email-wagi@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1345126336-20755-1-git-send-email-wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 16, 2012 at 04:12:11PM +0200, Daniel Wagner wrote:
> From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
> 
> Hi,
> 
> The patch #1 and #2 are there to be able to introduce (#3, #4) the 
> jump labels in task_cls_classid() and task_netprioidx(). The jump
> labels are needed to know when it is safe to access the controller. 
> For example not safe means the module is not yet loaded.
> 
> All those patches are just preparation for the center piece (#5) 
> of these series. This one will remove the dynamic subsystem ID
> generation and falls back to compile time generated IDs. 
> 
> This is the first result from the discussion around on the
> "cgroup cls & netprio 'cleanups'" patches.
> 
> This patches are against net-next
> 
> cheers,
> daniel
> 
> Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> Cc: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Cc: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> Cc: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
> Cc: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> 
> Daniel Wagner (5):
>   cgroup: Use empty task_cls_classid() when !CONFIG_NET_CLS(_MODULE)
>   cgroup: Move sock_update_classid() decleration to cls_cgroup.h
>   cgroup: Protect access to task_cls_classid() when built as module
>   cgroup: Protect access to task_netprioidx() when built as module
>   cgroup: Assign subsystem IDs during compile time
> 
>  include/linux/cgroup.h        | 20 +++++++++++++-------
>  include/linux/cgroup_subsys.h | 24 ++++++++++++------------
>  include/net/cls_cgroup.h      | 42 +++++++++++++++++++++++++++++-------------
>  include/net/netprio_cgroup.h  | 23 +++++++++++------------
>  include/net/sock.h            |  8 --------
>  kernel/cgroup.c               | 31 +++++++++----------------------
>  net/core/netprio_cgroup.c     | 17 ++++++-----------
>  net/core/sock.c               | 12 ++++++------
>  net/sched/cls_cgroup.c        | 18 +++++-------------
>  9 files changed, 91 insertions(+), 104 deletions(-)
> 
> -- 
> 1.7.12.rc1.16.g05a20c8
> 
> 


The series seems reasonable.  I presume you've testing building and running both
net_prio and net_cls as modules and monolithically?
Neil
