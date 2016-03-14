From: Michal Hocko <mhocko@kernel.org>
Subject: Re: userns, netns, and quick physical memory consumption by
 unprivileged user
Date: Mon, 14 Mar 2016 10:14:18 +0100
Message-ID: <20160314091417.GA11400@dhcp22.suse.cz>
References: <m3d1rclioc.fsf@gmail.com>
 <m3r3fhhx4c.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.osdl.org
To: "Yuriy M. Kaminskiy" <yumkam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:36561 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017AbcCNJOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 05:14:22 -0400
Content-Disposition: inline
In-Reply-To: <m3r3fhhx4c.fsf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri 11-03-16 18:06:59, Yuriy M. Kaminskiy wrote:
[...]
> And also tried with memcg:
>   t=/sys/fs/cgroup/memory/test1;mkdir $t;echo 0 >$t/tasks;
>   echo 48M >$t/memory.limit_in_bytes; su testuser [...]
> and it has not helped at all (rather opposite, it ended up with killed
> init and kernel panic; well, later is pure (un)luck; but point is, memcg
> apparently *CANNOT* curb net/ns allocations).

It seems you were using memcg v1 here. This didn't have the kernel
memory accounting enabled by default. With the v2 you get both user and
kernel (well some subset of it) accounting enabled. Whether we account
also netns related data structures sufficiently is a question. I haven't
checked.  But it would be worth trying and fix.

-- 
Michal Hocko
SUSE Labs
