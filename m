From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH UPDATED 1/3] vhost: replace vhost_workqueue with per-vhost
 kthread
Date: Wed, 28 Jul 2010 09:48:31 +0200
Message-ID: <4C4FE0CF.3070506@kernel.org>
References: <20100724191447.GA4972@redhat.com> <4C4BEAA2.6040301@kernel.org> <20100726152510.GA26223@redhat.com> <4C4DAB14.5050809@kernel.org> <20100726155014.GA26412@redhat.com> <4C4DB247.9060709@kernel.org> <4C4DB466.6000409@kernel.org> <20100726165114.GA27353@redhat.com> <4C4DDE7E.8030406@kernel.org> <4C4DE2AE.40302@kernel.org> <20100727191911.GA16350@redhat.com>
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
Received: from hera.kernel.org ([140.211.167.34]:50723 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753238Ab0G1HtQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jul 2010 03:49:16 -0400
In-Reply-To: <20100727191911.GA16350@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/27/2010 09:19 PM, Michael S. Tsirkin wrote:
>> Thinking a bit more about it, it kind of sucks that queueing to
>> another worker from worker->func() breaks flush.  Maybe the right
>> thing to do there is using atomic_t for done_seq?
> 
> I don't believe it will help: we might have:
> 
> worker1 runs work
> work requeues itself queued index = 1
> worker1 reads queued index = 1
> worker2 runs work
> work requeues itself queued index = 2
> worker2 runs work
> worker2 reads queued index = 2
> worker2 writes done index = 2
> worker1 writes done index = 1
> 
> As you see, done index got moved back.

Yeah, I think the flushing logic should be moved to the worker.  Are
you interested in doing it w/ your change?

Thanks.

-- 
tejun
