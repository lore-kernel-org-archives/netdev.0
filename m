From: "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v2 03/10] cgroup: net_cls: Protect access to
 task_cls_classid() when built as module
Date: Tue, 28 Aug 2012 07:47:25 -0700
Message-ID: <20120828144725.GR2961@linux.vnet.ibm.com>
References: <1345816904-21745-1-git-send-email-wagi@monom.org>
 <1345816904-21745-4-git-send-email-wagi@monom.org>
 <20120824232621.GQ21325@google.com>
 <503903BD.6020208@monom.org>
Reply-To: paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <503903BD.6020208-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 25, 2012 at 06:56:29PM +0200, Daniel Wagner wrote:
> On 25.08.2012 01:26, Tejun Heo wrote:
> >On Fri, Aug 24, 2012 at 04:01:37PM +0200, Daniel Wagner wrote:
> >>@@ -306,6 +312,11 @@ static void __exit exit_cgroup_cls(void)
> >>  	synchronize_rcu();
> >>  #endif
> >>
> >>+#if IS_MODULE(CONFIG_NET_CLS_CGROUP)
> >>+	static_key_slow_dec(&cgroup_cls_enabled);
> >>+	rcu_barrier();
> >
> >Why is this rcu_barrier() necessary?
> 
> I have read the rcubarrier.txt document and I got from that that an
> rcu_barrier() is needed when unloading a module. But maybe I got it
> wrong.
> 
> So the idea after disabling the jump lables all pending readers in
> task_cls_classid() have left. THe same thing is done in the old code
> with the dynamic id part. With the difference that synchronize_rcu()
> is used.

FWIW, the rcu_barrier() is needed only if the module uses call_rcu().
In that case it is required to ensure that all the resulting callbacks
execute before the module's .text is freed up.

							Thanx, Paul

> >In general, please explain what
> >synchronization is going on when using sync constructs which aren't
> >obvious - e.g. memory barriers, rcu barriers.
> 
> Sure, I will keep this in mind.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
