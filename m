From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Date: Fri, 6 Nov 2015 14:29:40 +0100
Message-ID: <20151106132940.GK4390@dhcp22.suse.cz>
References: <20151027154138.GA4665@cmpxchg.org>
 <20151027161554.GJ9891@dhcp22.suse.cz>
 <20151027164227.GB7749@cmpxchg.org>
 <20151029152546.GG23598@dhcp22.suse.cz>
 <20151029161009.GA9160@cmpxchg.org>
 <20151104104239.GG29607@dhcp22.suse.cz>
 <20151104195037.GA6872@cmpxchg.org>
 <20151105144002.GB15111@dhcp22.suse.cz>
 <20151105205522.GA1067@cmpxchg.org>
 <20151106090555.GK29259@esperanza>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	tj@kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20151106090555.GK29259@esperanza>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Fri 06-11-15 12:05:55, Vladimir Davydov wrote:
[...]
> If there are no objections, I'll prepare a patch switching to the
> white-list approach. Let's start from obvious things like fs_struct,
> mm_struct, task_struct, signal_struct, dentry, inode, which can be
> easily allocated from user space.

pipe buffers, kernel stacks and who knows what more.

> This should cover 90% of all
> allocations that should be accounted AFAICS. The rest will be added
> later if necessarily.

The more I think about that the more I am convinced that is the only
sane way forward. The only concerns I would have is how do we deal with
the old interface in cgroup1? We do not want to break existing
deployments which might depend on the current behavior. I doubt they are
but...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
