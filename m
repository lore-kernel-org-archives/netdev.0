From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: [PATCH] pkt_sched: Add lockdep annotation for qdisc locks
Date: Fri, 15 Aug 2008 01:56:49 +0300
Message-ID: <200808150156.49541.denys@visp.net.lb>
References: <20080814224129.GA2517@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:60673 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751863AbYHNW5x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 18:57:53 -0400
In-Reply-To: <20080814224129.GA2517@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Aug 15 01:54:49 194.146.153.146 [   57.428359]
Aug 15 01:54:49 194.146.153.146 [   57.428449] 
=============================================
Aug 15 01:54:49 194.146.153.146 [   57.428692] [ INFO: possible recursive 
locking detected ]
Aug 15 01:54:49 194.146.153.146 [   57.429018] 2.6.27-rc3-git2-build-0030 #7
Aug 15 01:54:49 194.146.153.146 [   
57.429018] ---------------------------------------------
Aug 15 01:54:49 194.146.153.146 [   57.429018] tc/2878 is trying to acquire 
lock:
Aug 15 01:54:49 194.146.153.146 [   57.429018]  (&qdisc_tx_lock
Aug 15 01:54:49 194.146.153.146 ){-+..}
Aug 15 01:54:49 194.146.153.146 , at:
Aug 15 01:54:49 194.146.153.146 [<c0270c93>] tc_ctl_tfilter+0x323/0x41c
Aug 15 01:54:49 194.146.153.146 [   57.429018]
Aug 15 01:54:49 194.146.153.146 [   57.429018] but task is already holding 
lock:
Aug 15 01:54:49 194.146.153.146 [   57.429018]  (&qdisc_tx_lock
Aug 15 01:54:49 194.146.153.146 ){-+..}
Aug 15 01:54:49 194.146.153.146 , at:
Aug 15 01:54:49 194.146.153.146 [<c0270c84>] tc_ctl_tfilter+0x314/0x41c
Aug 15 01:54:49 194.146.153.146 [   57.430005]
Aug 15 01:54:49 194.146.153.146 [   57.430005] other info that might help us 
debug this:
Aug 15 01:54:49 194.146.153.146 [   57.430005] 2 locks held by tc/2878:
Aug 15 01:54:49 194.146.153.146 [   57.430005]  #0:
Aug 15 01:54:49 194.146.153.146 (rtnl_mutex
Aug 15 01:54:49 194.146.153.146 ){--..}
Aug 15 01:54:49 194.146.153.146 , at:
Aug 15 01:54:49 194.146.153.146 [<c0269522>] rtnetlink_rcv+0x12/0x26
Aug 15 01:54:49 194.146.153.146 [   57.430005]  #1:
Aug 15 01:54:49 194.146.153.146 (&qdisc_tx_lock
Aug 15 01:54:49 194.146.153.146 ){-+..}
Aug 15 01:54:49 194.146.153.146 , at:
Aug 15 01:54:49 194.146.153.146 [<c0270c84>] tc_ctl_tfilter+0x314/0x41c
Aug 15 01:54:49 194.146.153.146 [   57.430005]
Aug 15 01:54:49 194.146.153.146 [   57.430005] stack backtrace:
Aug 15 01:54:49 194.146.153.146 [   57.430005] Pid: 2878, comm: tc Not tainted 
2.6.27-rc3-git2-build-0030 #7
Aug 15 01:54:49 194.146.153.146 [   57.430005]  [<c02ba45b>]
Aug 15 01:54:49 194.146.153.146 ?
Aug 15 01:54:49 194.146.153.146 printk+0xf/0x14
Aug 15 01:54:49 194.146.153.146 [   57.430005]  [<c013ed12>]
Aug 15 01:54:49 194.146.153.146 __lock_acquire+0xb3a/0x118a
Aug 15 01:54:49 194.146.153.146 [   57.430005]  [<c013f3aa>]
Aug 15 01:54:49 194.146.153.146 lock_acquire+0x48/0x64
Aug 15 01:54:49 194.146.153.146 [   57.430005]  [<c0270c93>]
Aug 15 01:54:49 194.146.153.146 ?
Aug 15 01:54:49 194.146.153.146 tc_ctl_tfilter+0x323/0x41c
Aug 15 01:54:49 194.146.153.146 [   57.430005]  [<c02bc958>]
Aug 15 01:54:49 194.146.153.146 _spin_lock_bh+0x20/0x2f
Aug 15 01:54:49 194.146.153.146 [   57.430005]  [<c0270c93>]
Aug 15 01:54:49 194.146.153.146 ?
Aug 15 01:54:49 194.146.153.146 tc_ctl_tfilter+0x323/0x41c
Aug 15 01:54:49 194.146.153.146 [   57.430005]  [<c0270c93>]
Aug 15 01:54:49 194.146.153.146 tc_ctl_tfilter+0x323/0x41c
Aug 15 01:54:49 194.146.153.146 [   57.430005]  [<c013dabf>]
Aug 15 01:54:49 194.146.153.146 ?
Aug 15 01:54:49 194.146.153.146 trace_hardirqs_on+0xb/0xd
Aug 15 01:54:49 194.146.153.146 [   57.430005]  [<c013da93>]
Aug 15 01:54:49 194.146.153.146 ?
Aug 15 01:54:49 194.146.153.146 trace_hardirqs_on_caller+0xe1/0x102
Aug 15 01:54:49 194.146.153.146 [   57.430005]  [<c0270970>]
Aug 15 01:54:49 194.146.153.146 ?
Aug 15 01:54:49 194.146.153.146 tc_ctl_tfilter+0x0/0x41c
Aug 15 01:54:49 194.146.153.146 [   57.430005]  [<c02696ce>]
Aug 15 01:54:49 194.146.153.146 rtnetlink_rcv_msg+0x198/0x1b2
Aug 15 01:54:49 194.146.153.146 [   57.430005]  [<c0269536>]
Aug 15 01:54:49 194.146.153.146 ?
Aug 15 01:54:49 194.146.153.146 rtnetlink_rcv_msg+0x0/0x1b2
Aug 15 01:54:49 194.146.153.146 [   57.430005]  [<c027526b>]
Aug 15 01:54:49 194.146.153.146 netlink_rcv_skb+0x30/0x75
Aug 15 01:54:49 194.146.153.146 [   57.430005]  [<c026952e>]
Aug 15 01:54:49 194.146.153.146 rtnetlink_rcv+0x1e/0x26
Aug 15 01:54:49 194.146.153.146 [   57.430005]  [<c0274e02>]
Aug 15 01:54:49 194.146.153.146 netlink_unicast+0x1a9/0x20a
Aug 15 01:54:49 194.146.153.146 [   57.430005]  [<c0275085>]
Aug 15 01:54:49 194.146.153.146 netlink_sendmsg+0x222/0x22f
Aug 15 01:54:49 194.146.153.146 [   57.430005]  [<c0256fd1>]
Aug 15 01:54:49 194.146.153.146 sock_sendmsg+0xca/0xe1
Aug 15 01:54:49 194.146.153.146 [   57.430005]  [<c0132301>]
Aug 15 01:54:49 194.146.153.146 ?
Aug 15 01:54:49 194.146.153.146 autoremove_wake_function+0x0/0x33
Aug 15 01:54:49 194.146.153.146 [   57.430005]  [<c0132301>]
Aug 15 01:54:49 194.146.153.146 ?
Aug 15 01:54:49 194.146.153.146 autoremove_wake_function+0x0/0x33
Aug 15 01:54:49 194.146.153.146 [   57.430005]  [<c025d441>]
Aug 15 01:54:49 194.146.153.146 ?
Aug 15 01:54:49 194.146.153.146 verify_iovec+0x40/0x6f
Aug 15 01:54:49 194.146.153.146 [   57.430005]  [<c0257127>]
Aug 15 01:54:49 194.146.153.146 sys_sendmsg+0x13f/0x192
Aug 15 01:54:49 194.146.153.146 [   57.430005]  [<c025796f>]
Aug 15 01:54:49 194.146.153.146 ?
Aug 15 01:54:49 194.146.153.146 sys_recvmsg+0x116/0x17b
Aug 15 01:54:49 194.146.153.146 [   57.430005]  [<c0166f71>]
Aug 15 01:54:49 194.146.153.146 ?
Aug 15 01:54:49 194.146.153.146 do_sync_read+0xab/0xe9
Aug 15 01:54:49 194.146.153.146 [   57.430005]  [<c0132301>]
Aug 15 01:54:49 194.146.153.146 ?
Aug 15 01:54:49 194.146.153.146 autoremove_wake_function+0x0/0x33
Aug 15 01:54:49 194.146.153.146 [   57.430005]  [<c0257f57>]
Aug 15 01:54:49 194.146.153.146 sys_socketcall+0x14b/0x180
Aug 15 01:54:49 194.146.153.146 [   57.430005]  [<c01dd5d0>]
Aug 15 01:54:49 194.146.153.146 ?
Aug 15 01:54:49 194.146.153.146 trace_hardirqs_on_thunk+0xc/0x10
Aug 15 01:54:49 194.146.153.146 [   57.430005]  [<c0103861>]
Aug 15 01:54:49 194.146.153.146 sysenter_do_call+0x12/0x35
Aug 15 01:54:49 194.146.153.146 [   57.430005]  =======================

and system dead.
More details and messages at 
http://www.nuclearcat.com/files/dead-2.6.27-rc3.txt

On Friday 15 August 2008, Jarek Poplawski wrote:
> On Thu, Aug 14, 2008 at 06:07:12PM +0300, Denys Fedoryshchenko wrote:
> > On 2.6.27 rc3-git2 i am getting softlockup after 60-120 seconds after
> > running. Netconsole is almost dead, i tried to use it get stacktrace, but
> > it is sending few lines of header only.
> >
> > It happens when many tc sessions running in parallel, thats only info i
> > have now.
> >
> > Update: got interesting info, maybe this is the issue:
>
> Denys, I doubt this patch can fix these problems, but maybe you'll
> get another, more useful warnings.
>
> Thanks,
> Jarek P.
>
> ------------------>
>
> pkt_sched: Add lockdep annotation for qdisc locks
>
> Qdisc locks are initialized in the same function, qdisc_alloc(), so
> lockdep can't distinguish tx qdisc lock from rx and reports "possible
> recursive locking detected" when both these locks are taken eg. while
> using act_mirred with ifb. This looks like a false positive. Anyway,
> after this patch these locks will be reported more exactly.
>
>
> Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
>
> ---
>
>  net/sched/sch_api.c |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)
>
> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index c25465e..bf84181 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c
> @@ -27,6 +27,7 @@
>  #include <linux/kmod.h>
>  #include <linux/list.h>
>  #include <linux/hrtimer.h>
> +#include <linux/lockdep.h>
>
>  #include <net/net_namespace.h>
>  #include <net/sock.h>
> @@ -707,6 +708,10 @@ static int qdisc_graft(struct net_device *dev, struct
> Qdisc *parent, return err;
>  }
>
> +/* lockdep annotation is needed for ingress; egress gets it only for name
> */ +static struct lock_class_key qdisc_tx_lock;
> +static struct lock_class_key qdisc_rx_lock;
> +
>  /*
>     Allocate and initialize new qdisc.
>
> @@ -767,6 +772,7 @@ qdisc_create(struct net_device *dev, struct
> netdev_queue *dev_queue, if (handle == TC_H_INGRESS) {
>  		sch->flags |= TCQ_F_INGRESS;
>  		handle = TC_H_MAKE(TC_H_INGRESS, 0);
> +		lockdep_set_class(qdisc_lock(sch), &qdisc_rx_lock);
>  	} else {
>  		if (handle == 0) {
>  			handle = qdisc_alloc_handle(dev);
> @@ -774,6 +780,7 @@ qdisc_create(struct net_device *dev, struct
> netdev_queue *dev_queue, if (handle == 0)
>  				goto err_out3;
>  		}
> +		lockdep_set_class(qdisc_lock(sch), &qdisc_tx_lock);
>  	}
>
>  	sch->handle = handle;


