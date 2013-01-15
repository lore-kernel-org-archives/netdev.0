From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH v3] cgroup: net_cls: traffic counter based on
 classification control cgroup
Date: Tue, 15 Jan 2013 07:05:09 -0800
Message-ID: <1358262309.8744.5760.camel@edumazet-glaptop>
References: <20130115133351.GA8633@aperevalov>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexey Perevalov <a.perevalov-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130115133351.GA8633@aperevalov>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-01-15 at 17:33 +0400, Alexey Perevalov wrote:
> Hello
> 
> I would like to represent next version of patch I sent before
> cgroup: "net_cls: traffic counter based on classification control cgroup"
> 
> The main idea is the same as was. It keeping counter in control groups, but now uses atomic instead of resource_counters.
> 
> Signed-off-by: Alexey Perevalov <a.perevalov-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
> ---
>  include/net/cls_cgroup.h         |  200 ++++++++++++++++++++++++++++++++++----
>  include/net/cls_counter_holder.h |   26 +++++
>  init/Kconfig                     |   25 +++++
>  kernel/cgroup.c                  |    2 +
>  kernel/res_counter.c             |    4 +
>  net/core/dev.c                   |    6 ++
>  net/ipv4/tcp.c                   |   27 ++++-
>  net/ipv4/udp.c                   |    6 ++
>  net/sched/Kconfig                |   11 ---
>  net/sched/Makefile               |    1 +
>  net/sched/cls_cgroup.c           |  194 +++++++++++++++++++++++++++++++++++-
>  net/sched/cls_counter_holder.c   |  144 +++++++++++++++++++++++++++
>  12 files changed, 611 insertions(+), 35 deletions(-)
>  create mode 100644 include/net/cls_counter_holder.h
>  create mode 100644 net/sched/cls_counter_holder.c

Sorry, there are too many issues with this patch and I have not
a lot of time to review it.

0) No changelog or documentation

1) There is no way you need to add kludges in tcp and udp for this
accounting. Retransmitted packets should not be ignored for example.

2) Ugly #ifdef in c files. Don't do that please.

3) No check of kmalloc() returns (can be NULL)
