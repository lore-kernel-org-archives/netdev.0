From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH 00/14]: Killing qdisc->ops->requeue().
Date: Tue, 14 Oct 2008 13:37:14 -0700
Message-ID: <48F502FA.4040004@intel.com>
References: <20081014095246.GA10804@ff.dom.local> <48F4CBBA.7070004@intel.com> <20081014191554.GA2953@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:15215 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750899AbYJNUmR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Oct 2008 16:42:17 -0400
In-Reply-To: <20081014191554.GA2953@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Tue, Oct 14, 2008 at 09:41:30AM -0700, Alexander Duyck wrote:
> ...
>> I think if anything it seems like you guys actually found the cpu
>> performance issue a while back in the fact that the dev_requeue_skb was
>> calling __netif_schedule when requeuing on a stopped queue.  That is the
>> one piece I would say needs to be changed so that you only call
>> __netif_schedule if the skb is not going to a stopped queue.
> 
> BTW, since one of the other "dreams" of killing requeuing failed, I
> think this proposal is worth checking, but David was concerned about
> some issues with buggy drivers after __netif_schedule() removing.
> 
> Jarek P.

I would say not to remove it.  Just add a check to verify that the queue 
the packet is bound for is not stopped prior to calling it.  If the 
queue is stopped it should be rescheduled by the wake_queue call when 
the device has cleared the queue.

Unfortunately I am currently working on other projects so I don't really 
  have the time to create and test a patch for this.  Hopefully my input 
has proven useful.

Thanks,

Alex
