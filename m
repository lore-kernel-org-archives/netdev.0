From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec] xfrm: policy: init locks early
Date: Fri, 10 Feb 2017 08:35:40 +0100
Message-ID: <20170210073540.GY30338@gauss.secunet.com>
References: <CACT4Y+Yd3zgOgtsAjdsREY3vm=bCNif-keYgvFeWGMckWrrjEw@mail.gmail.com>
 <20170208105229.27285-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <dvyukov@google.com>,
        <linux-kernel@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170208105229.27285-1-fw@strlen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 08, 2017 at 11:52:29AM +0100, Florian Westphal wrote:
> Dmitry reports following splat:
>  INFO: trying to register non-static key.
>  the code is fine but needs lockdep annotation.
>  turning off the locking correctness validator.
>  CPU: 0 PID: 13059 Comm: syz-executor1 Not tainted 4.10.0-rc7-next-20170207 #1
> [..]
>  spin_lock_bh include/linux/spinlock.h:304 [inline]
>  xfrm_policy_flush+0x32/0x470 net/xfrm/xfrm_policy.c:963
>  xfrm_policy_fini+0xbf/0x560 net/xfrm/xfrm_policy.c:3041
>  xfrm_net_init+0x79f/0x9e0 net/xfrm/xfrm_policy.c:3091
>  ops_init+0x10a/0x530 net/core/net_namespace.c:115
>  setup_net+0x2ed/0x690 net/core/net_namespace.c:291
>  copy_net_ns+0x26c/0x530 net/core/net_namespace.c:396
>  create_new_namespaces+0x409/0x860 kernel/nsproxy.c:106
>  unshare_nsproxy_namespaces+0xae/0x1e0 kernel/nsproxy.c:205
>  SYSC_unshare kernel/fork.c:2281 [inline]
> 
> Problem is that when we get error during xfrm_net_init we will call
> xfrm_policy_fini which will acquire xfrm_policy_lock before it was
> initialized.  Just move it around so locks get set up first.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Fixes: 283bc9f35bbbcb0e9 ("xfrm: Namespacify xfrm state/policy locks")
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks everyone!
