From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 4/5] sock, cgroup: add sock->sk_cgroup
Date: Tue, 17 Nov 2015 17:17:57 -0500
Message-ID: <20151117221757.GI22864@mtj.duckdns.org>
References: <1447789240-29394-1-git-send-email-tj@kernel.org>
 <1447789240-29394-5-git-send-email-tj@kernel.org>
 <20151117.162554.314531574043190960.davem@davemloft.net>
 <20151117213126.GH22864@mtj.duckdns.org>
 <564BA0BE.7050302@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, pablo@netfilter.org,
	kaber@trash.net, kadlec@blackhole.kfki.hu, lizefan@huawei.com,
	hannes@cmpxchg.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, daniel.wagner@bmw-carit.de,
	nhorman@tuxdriver.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <564BA0BE.7050302@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Daniel.

On Tue, Nov 17, 2015 at 10:48:46PM +0100, Daniel Borkmann wrote:
> >Unfortunately, sk->sk_cgrp_prioidx is an arbitrary value which can be
> >configured through "net_cls.classid".  :(
> 
> Hmm, isn't net_prio independent of net_cls?

Ah, yeah, I was mixing up the two but the story is the same for both.
net_prio configures the prioidx and net_cls the classid and the two
may or may not (but more likely not) be on the same hierarchy and
definitely not on the cgroup2 hierarchy, so you can't really access
them through a single ->sk_cgroup pointer.  After all, that's why we
ended up with these controllers.

Thanks.

-- 
tejun
