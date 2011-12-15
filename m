From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 2/2] Explicitly call tcp creation and init from
 memcontrol.c
Date: Fri, 16 Dec 2011 01:13:16 +0900
Message-ID: <20111216011316.8d58bc8f.kamezawa.hiroyu@jp.fujitsu.com>
References: <1323941672-14324-1-git-send-email-glommer@parallels.com>
	<1323941672-14324-3-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1323941672-14324-3-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Dec 2011 13:34:32 +0400
Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> wrote:

> Walking the proto_list holds a read_lock, which prevents us from doing
> allocations. Splitting the tcp create function into create + init is
> good, but it is not enough since create_files will do allocations as well
> (dentry ones, mostly).
> 
> Since this does not involve any protocol state, I propose we call the tcp
> functions explicitly from memcontrol.c
> 
> With this, we lose by now the ability of doing cgroup memcontrol for
> protocols that are loaded as modules. But at least the ones I have in mind
> won't really need it (tcp_ipv6 being the only one, but it uses the same data
> structures as tcp_ipv4). So I believe this to be the simpler solution to this
> problem.
> 
> Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> CC: Hiroyouki Kamezawa <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> CC: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> CC: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> CC: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>

Could you remake the patch onto the 'latest' linux-next ?
As Dave mentioned, some bandaids are already applied and this patch hunks.

Thanks,
-Kame

--
To unsubscribe from this list: send the line "unsubscribe cgroups" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
