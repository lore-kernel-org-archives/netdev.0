From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 00/14]: Killing qdisc->ops->requeue().
Date: Tue, 14 Oct 2008 20:37:30 +0200
Message-ID: <20081014183730.GC2548@ami.dom.local>
References: <20081014095246.GA10804@ff.dom.local> <48F4CBBA.7070004@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:15192 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751414AbYJNShM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 14:37:12 -0400
Received: by ug-out-1314.google.com with SMTP id k3so1017978ugf.37
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 11:37:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48F4CBBA.7070004@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 14, 2008 at 09:41:30AM -0700, Alexander Duyck wrote:
...
> I still do not agree with this change.  It essentially breaks multiq as  
> we are right back to all queues being stopped because of one packet in  
> the qdisc->requeue list.

Good news! I've withdrawn this patch-set (for another reason yet).

> I think if anything it seems like you guys actually found the cpu  
> performance issue a while back in the fact that the dev_requeue_skb was  
> calling __netif_schedule when requeuing on a stopped queue.  That is the  
> one piece I would say needs to be changed so that you only call  
> __netif_schedule if the skb is not going to a stopped queue.

Alexender, actually I've remembered your concerns, and I waited with
this mostly for you. Since you didn't write I thought you've changed
your mind in the meantime. Anyway, current changes are really minimal
and easy to revert, so I wonder why you don't try to convince us with
some patches and/or test results.

IMHO, even if you are right about some downsides of the current
"simplistic" solution, which I think are overestimated (since multiq
does it's own checks beforehand, especially when used as a root it
should almost never have it's packets requeued - otherwise, according
to David, it's a buggy driver), but it seems it wasn't only me thinking
your proposal adds too much code duplication.

And, after all, you seem to think everything should be adapted for the
sake of sch_multiq, which could be true in the future, but maybe we
should wait with this for users' requests?

Thanks,
Jarek P.
