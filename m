From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [net-next PATCH v1] net: netprio_cgroup: rework update socket
 logic
Date: Sat, 21 Jul 2012 13:18:55 -0400
Message-ID: <20120721171854.GA6099@neilslaptop.think-freely.org>
References: <20120720203925.30782.36819.stgit@jf-dev1-dcblab>
 <20120721020015.GA3827@neilslaptop.think-freely.org>
 <500AE08B.5040602@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, gaofeng@cn.fujitsu.com, lizefan@huawei.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33807 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135Ab2GURTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2012 13:19:10 -0400
Content-Disposition: inline
In-Reply-To: <500AE08B.5040602@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 21, 2012 at 10:02:03AM -0700, John Fastabend wrote:
> On 7/20/2012 7:00 PM, Neil Horman wrote:
> >On Fri, Jul 20, 2012 at 01:39:25PM -0700, John Fastabend wrote:
> >>Instead of updating the sk_cgrp_prioidx struct field on every send
> >>this only updates the field when a task is moved via cgroup
> >>infrastructure.
> >>
> >>This allows sockets that may be used by a kernel worker thread
> >>to be managed. For example in the iscsi case today a user can
> >>put iscsid in a netprio cgroup and control traffic will be sent
> >>with the correct sk_cgrp_prioidx value set but as soon as data
> >>is sent the kernel worker thread isssues a send and sk_cgrp_prioidx
> >>is updated with the kernel worker threads value which is the
> >>default case.
> >>
> >>It seems more correct to only update the field when the user
> >>explicitly sets it via control group infrastructure. This allows
> >>the users to manage sockets that may be used with other threads.
> >>
> >>Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> >I like the idea, but IIRC last time we tried this I think it caused problems
> >with processes that shared sockets.  That is to say, if you have a parent and
> >child process that dup an socket descriptior, and put them in separate cgroups,
> >you get unpredictable results, as the socket gets assigned a priority based on
> >the last processed that moved cgroups.
> >
> >Neil
> >
> 
> Shared sockets creates strange behavior as it exists today. If a dup
> of the socket fd is created the private data is still shared right. So
> in this case the sk_cgrp_prioidx value is going to get updated by both
> threads and then it is a race to see what it happens to be set to in
> the xmit path.
> 
> With this patch at least the behavior is deterministic. Without it
> I can create the above scenario but have no way to determine what the
> skb priority will actually be set to.
> 
> .John
> 
Ok, I can buy that.  Lets give this a try:

Acked-by: Neil Horman <nhorman@tuxdriver.com>
