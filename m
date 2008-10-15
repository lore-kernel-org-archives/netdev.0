From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 00/14]: Killing qdisc->ops->requeue().
Date: Wed, 15 Oct 2008 06:45:22 +0000
Message-ID: <20081015064522.GA4215@ff.dom.local>
References: <20081014095246.GA10804@ff.dom.local> <48F4CBBA.7070004@intel.com> <20081014191554.GA2953@ami.dom.local> <48F502FA.4040004@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.180]:4880 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751024AbYJOGp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2008 02:45:28 -0400
Received: by ik-out-1112.google.com with SMTP id c30so1888535ika.5
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 23:45:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48F502FA.4040004@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 14, 2008 at 01:37:14PM -0700, Alexander Duyck wrote:
> Jarek Poplawski wrote:
>> On Tue, Oct 14, 2008 at 09:41:30AM -0700, Alexander Duyck wrote:
>> ...
>>> I think if anything it seems like you guys actually found the cpu
>>> performance issue a while back in the fact that the dev_requeue_skb was
>>> calling __netif_schedule when requeuing on a stopped queue.  That is the
>>> one piece I would say needs to be changed so that you only call
>>> __netif_schedule if the skb is not going to a stopped queue.
>>
>> BTW, since one of the other "dreams" of killing requeuing failed, I
>> think this proposal is worth checking, but David was concerned about
>> some issues with buggy drivers after __netif_schedule() removing.
>>
>> Jarek P.
>
> I would say not to remove it.  Just add a check to verify that the queue  
> the packet is bound for is not stopped prior to calling it.  If the  
> queue is stopped it should be rescheduled by the wake_queue call when  
> the device has cleared the queue.

Sure, I meant "after __netif_schedule() call removing". Anyway, there
were a discussion on something like this:

http://marc.info/?l=linux-netdev&m=122197536025956&w=2

> Unfortunately I am currently working on other projects so I don't really  
>  have the time to create and test a patch for this.  Hopefully my input  
> has proven useful.

Without this __netif_schedule() call we should expect at least higher
cpu use here while packets are xmitted to a stopped queue compared to
older kernels or the current one (especially with multi qdisc/class/
filter configs), so first we should know this requeuing from the top is
really necessary, and I didn't see anything convincing about this yet.

Thanks,
Jarek P.
