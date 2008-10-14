From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH 00/14]: Killing qdisc->ops->requeue().
Date: Tue, 14 Oct 2008 09:41:30 -0700
Message-ID: <48F4CBBA.7070004@intel.com>
References: <20081014095246.GA10804@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Jarek Poplawski <jarkao2@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9521 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751155AbYJNQll (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Oct 2008 12:41:41 -0400
In-Reply-To: <20081014095246.GA10804@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> The aim of this patch-set is to finish changes proposed by David S.
> Miller in his patch-set with the same subject from Mon, 18 Aug 2008.
> The first two patches were applied with some modifications, so, to
> apply the rest, there were needed some changes.
> 
> Original David's patches include additional info, but signed-off-by
> is removed because of changed context. I expect they will be merged
> and signed off by David as an author, anyway.
> 
> The qdisc->requeue list idea is to limit requeuing to one level only,
> so a parent can requeue to its child only. This list is then tried
> first while dequeuing (qdisc_dequeue()), except at the top level,
> so packets could be requeued only by qdiscs, not by qdisc_restart()
> after xmit errors.

I still do not agree with this change.  It essentially breaks multiq as 
we are right back to all queues being stopped because of one packet in 
the qdisc->requeue list.

I think if anything it seems like you guys actually found the cpu 
performance issue a while back in the fact that the dev_requeue_skb was 
calling __netif_schedule when requeuing on a stopped queue.  That is the 
one piece I would say needs to be changed so that you only call 
__netif_schedule if the skb is not going to a stopped queue.

Thanks,

Alex
