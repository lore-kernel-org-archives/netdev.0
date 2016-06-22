From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next 4/4] net_sched: generalize bulk dequeue
Date: Wed, 22 Jun 2016 17:03:23 +0200
Message-ID: <20160622170323.27a24aee@redhat.com>
References: <1466576212-15012-1-git-send-email-edumazet@google.com>
	<1466576212-15012-5-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <daniel@iogearbox.net>, brouer@redhat.com
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56863 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752807AbcFVPDa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 11:03:30 -0400
In-Reply-To: <1466576212-15012-5-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Jun 2016 23:16:52 -0700
Eric Dumazet <edumazet@google.com> wrote:

> When qdisc bulk dequeue was added in linux-3.18 (commit
> 5772e9a3463b "qdisc: bulk dequeue support for qdiscs
> with TCQ_F_ONETXQUEUE"), it was constrained to some
> specific qdiscs.

Thanks for extending this!

> With some extra care, we can extend this to all qdiscs,
> so that typical traffic shaping solutions can benefit from
> small batches (8 packets in this patch).

I'm fine with limiting this to 8 packets (xmit_more), as that seem to
be the minimum needed TX batch size (according to Luigi's original
netmap article[1] figure 7) for doing 10G wirespeed.

[1] http://info.iet.unipi.it/~luigi/papers/20120503-netmap-atc12.pdf
 

> For example, HTB is often used on some multi queue device.
> And bonding/team are multi queue devices...
> 
> Idea is to bulk-dequeue packets mapping to the same transmit queue.
> 
> This brings between 35 and 80 % performance increase in HTB setup
> under pressure on a bonding setup :
> 
> 1) NUMA node contention :   610,000 pps -> 1,110,000 pps
> 2) No node contention   : 1,380,000 pps -> 1,930,000 pps
> 
> Now we should work to add batches on the enqueue() side ;)

Yes, please! :-))) That will be the next big step!


> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Cc: Jesper Dangaard Brouer <brouer@redhat.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: Florian Westphal <fw@strlen.de>
> Cc: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

This is great stuff!

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
