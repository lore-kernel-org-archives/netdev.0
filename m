From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/3] workqueue: Add an API to create a singlethread	workqueue
 attached to the current task's cgroup
Date: Thu, 27 May 2010 18:56:20 +0200
Message-ID: <4BFEA434.6080405@kernel.org>
References: <1274227491.2370.110.camel@w-sridhar.beaverton.ibm.com> <20100527091426.GA6308@redhat.com> <20100527124448.GA4241@redhat.com> <20100527131254.GB7974@redhat.com> <4BFE9ABA.6030907@kernel.org> <20100527163954.GA21710@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Oleg Nesterov <oleg@redhat.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:35418 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757964Ab0E0Q5r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 May 2010 12:57:47 -0400
In-Reply-To: <20100527163954.GA21710@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 05/27/2010 06:39 PM, Michael S. Tsirkin wrote:
>> Unless you're gonna convert every driver to use this
>> special kind of workqueue (and what happens when multiple tasks from
>> different cgroups share the driver?),
> 
> We'll then create a workqueue per task. Each workqueue will have the
> right cgroup. But we are not trying to selve the problem for
> every driver.

Ah... I see.  You're gonna use multiple workqueues.  Once concern that
I have is that this is abuse of workqueue interface to certain level
and depends on the implementation detail of workqueue rather than its
intended usage model.  stop_machine() was a similar case and in the
end it was better served by a different mechanism built on kthread
directly (cpu_stop).  Wouldn't it be cleaner to use kthread directly
for your case too?  You're basically trying to use workqueue as a
frontend to kthread, so...

Thanks.

-- 
tejun
