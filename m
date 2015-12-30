From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 05/12] net: sched: per cpu gso handlers
Date: Wed, 30 Dec 2015 21:26:33 +0100
Message-ID: <20151230212633.23fc9b7c@redhat.com>
References: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
	<20151230175249.26257.99.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, eric.dumazet@gmail.com, jhs@mojatatu.com,
	aduyck@mirantis.com, davem@davemloft.net,
	john.r.fastabend@intel.com, netdev@vger.kernel.org,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43595 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754506AbbL3U0j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Dec 2015 15:26:39 -0500
In-Reply-To: <20151230175249.26257.99.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Dec 2015 09:52:49 -0800
John Fastabend <john.fastabend@gmail.com> wrote:

> The net sched infrastructure has a gso ptr that points to skb structs
> that have failed to be enqueued by the device driver.

What about fixing up the naming "gso" to something else like "requeue",
in the process (or by an pre-patch) ?


> This can happen when multiple cores try to push a skb onto the same
> underlying hardware queue resulting in lock contention. This case is
> handled by a cpu collision handler handle_dev_cpu_collision(). Another
> case occurs when the stack overruns the drivers low level tx queues
> capacity. Ideally these should be a rare occurrence in a well-tuned
> system but they do happen.
> 
> To handle this in the lockless case use a per cpu gso field to park
> the skb until the conflict can be resolved. Note at this point the
> skb has already been popped off the qdisc so it has to be handled
> by the infrastructure.

I generally like this idea of resolving this per cpu.  (I stalled here,
on the requeue issue, last time I implemented a lockless qdisc
approach).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
