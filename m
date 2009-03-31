From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 15/17] kvm: add dynamic IRQ support
Date: Tue, 31 Mar 2009 23:59:13 +0300
Message-ID: <49D28421.4020308@redhat.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <20090331184405.28333.59205.stgit@dev.haskins.net> <49D26CFE.1060700@redhat.com> <49D2718F.9070203@novell.com> <49D27950.9020801@redhat.com> <49D27DD3.5080609@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:46287 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753094AbZCaU6p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2009 16:58:45 -0400
In-Reply-To: <49D27DD3.5080609@novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gregory Haskins wrote:
>> Won't this have scaling issues?  One IRQ means one target vcpu. 
>> Whereas I'd like virtio devices to span multiple queues, each queue
>> with its own MSI IRQ.
>>     
> Hmm..you know I hadnt really thought of it that way, but you have a
> point.  To clarify, my design actually uses one IRQ per "eventq", where
> we can have an arbitrary number of eventq's defined (note: today I only
> define one eventq, however).  An eventq is actually a shm-ring construct
> where I can pass events up to the host like "device added" or "ring X
> signaled".  Each individual device based virtio-ring would then
> aggregates "signal" events onto this eventq mechanism to actually inject
> events to the host.  Only the eventq itself injects an actual IRQ to the
> assigned vcpu.
>   

You will get get cachelines bounced around when events from different 
devices are added to the queue.  On the plus side, a single injection 
can contain interrupts for multiple devices.

I'm not sure how useful this coalescing is; certainly you will never see 
it on microbenchmarks, but that doesn't mean it's not useful.


-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

