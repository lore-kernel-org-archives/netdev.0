From: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH 3/3] net: introduce res_counter_charge_nofail() for
 socket allocations
Date: Tue, 24 Jan 2012 09:15:52 +0100
Message-ID: <20120124081552.GB1660@cmpxchg.org>
References: <1327071436-20763-1-git-send-email-glommer@parallels.com>
 <1327071436-20763-4-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Laurent Chavey <chavey-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1327071436-20763-4-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 20, 2012 at 06:57:16PM +0400, Glauber Costa wrote:
> There is a case in __sk_mem_schedule(), where an allocation
> is beyond the maximum, but yet we are allowed to proceed.
> It happens under the following condition:
> 
> 	sk->sk_wmem_queued + size >= sk->sk_sndbuf
> 
> The network code won't revert the allocation in this case,
> meaning that at some point later it'll try to do it. Since
> this is never communicated to the underlying res_counter
> code, there is an inbalance in res_counter uncharge operation.
> 
> I see two ways of fixing this:
> 
> 1) storing the information about those allocations somewhere
>    in memcg, and then deducting from that first, before
>    we start draining the res_counter,
> 2) providing a slightly different allocation function for
>    the res_counter, that matches the original behavior of
>    the network code more closely.
> 
> I decided to go for #2 here, believing it to be more elegant,
> since #1 would require us to do basically that, but in a more
> obscure way.
> 
> Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
> Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
> CC: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> CC: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> CC: Laurent Chavey <chavey-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Acked-by: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
