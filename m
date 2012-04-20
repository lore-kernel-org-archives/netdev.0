From: Stephen Boyd <sboyd@codeaurora.org>
Subject: Re: [PATCH 1/2] workqueue: Catch more locking problems with flush_work()
Date: Fri, 20 Apr 2012 01:18:19 -0700
Message-ID: <4F911BCB.7010809@codeaurora.org>
References: <1334805958-29119-1-git-send-email-sboyd@codeaurora.org> <20120419081002.GB3963@zhy> <4F905B30.4080501@codeaurora.org> <20120420052633.GA16219@zhy> <20120420060101.GA16563@zhy> <4F9101A7.5010100@codeaurora.org> <20120420071759.GA17846@zhy>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	netdev@vger.kernel.org, Ben Dooks <ben-linux@fluff.org>
To: Yong Zhang <yong.zhang0@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:30881 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756491Ab2DTISU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 04:18:20 -0400
In-Reply-To: <20120420071759.GA17846@zhy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/20/2012 12:18 AM, Yong Zhang wrote:
> On Thu, Apr 19, 2012 at 11:26:47PM -0700, Stephen Boyd wrote:
>> complain in the case where the work is not queued. That case is not a
>> false positive. We will get a lockdep warning if the work is running
> IIRC, flush_work() is just a nop when a work is not queued nor running.

Agreed, but it's better to always print a lockdep warning instead of
only when the deadlock is going to occur.

>
>> (when start_flush_work() returns true) solely with the
>> lock_map_acquire() on cwq->wq->lockdep_map.
> Yeah, that is the point we use lockdep to detect deadlock for workqueue.
>
> But when looking at start_flush_work(), for some case
> !(cwq->wq->saved_max_active == 1 || cwq->wq->flags & WQ_RESCUER),
> lock_map_acquire_read() is called, but recursive read is not added to
> the chain list. So when lock_map_acquire_read(&cwq->wq->lockdep_map)
> is called, deadlock will not be detected. I hope you don't hit that
> special case.

Hmm. Originally I had what you suggested in my patch but I left it out
because I wasn't sure if it would cause false positives. Do you see any
possibility for false positives? I'll add it back in if not.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.
