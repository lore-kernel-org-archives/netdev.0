From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/5] cgroup: record ancestor IDs and reimplement
 cgroup_is_descendant() using it
Date: Tue, 17 Nov 2015 18:03:35 -0500
Message-ID: <20151117230335.GK22864@mtj.duckdns.org>
References: <1447789240-29394-1-git-send-email-tj@kernel.org>
 <1447789240-29394-2-git-send-email-tj@kernel.org>
 <alpine.LSU.2.20.1511172353350.13966@nerf40.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, lizefan@huawei.com, hannes@cmpxchg.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	daniel@iogearbox.net, daniel.wagner@bmw-carit.de,
	nhorman@tuxdriver.com
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.20.1511172353350.13966@nerf40.vanv.qr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 17, 2015 at 11:54:54PM +0100, Jan Engelhardt wrote:
> 
> On Tuesday 2015-11-17 20:40, Tejun Heo wrote:
> >+static inline bool cgroup_is_descendant(struct cgroup *cgrp,
> >+					struct cgroup *ancestor)
> 
> (const struct group *cgrp, const struct group *ancestor)

I'm not sure about using const on complex data structures.  It often
ends up causing more mess than being helpful.  It's never consistent
and often can't be - e.g. you throw in an iteration macro and then
realize that there need to be two separate variants of iteration
macros for consts and !consts after propagating const through the call
chains and then end up doing forced casts.

Thanks.

-- 
tejun
