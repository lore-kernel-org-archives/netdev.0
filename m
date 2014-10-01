From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH V5] qdisc: bulk dequeue support for qdiscs with
 TCQ_F_ONETXQUEUE
Date: Wed, 1 Oct 2014 21:47:00 +0200
Message-ID: <20141001214700.18b16387@redhat.com>
References: <20140930085114.24043.81310.stgit@dragon>
	<542A8EF9.10403@mojatatu.com>
	<20140930.142038.235338672810639160.davem@davemloft.net>
	<542BFEF3.7020302@mojatatu.com>
	<CA+mtBx8rVu9FXtnc18n22L9LP=t=3Pso7U2yvvLcnny57w8aXg@mail.gmail.com>
	<542C1F1F.90404@mojatatu.com>
	<20141001192840.5679a671@redhat.com>
	<542C4E0D.4050404@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>,
	Toke =?UTF-8?B?SMO4aWxhbmQtSsO4cmdlbnNl?= =?UTF-8?B?bg==?=
	<toke@toke.dk>, brouer@redhat.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35367 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750945AbaJATrW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2014 15:47:22 -0400
In-Reply-To: <542C4E0D.4050404@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 01 Oct 2014 14:55:09 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> On 10/01/14 13:28, Jesper Dangaard Brouer wrote:
> 
> > Thus, code is activated only when q->qlen is >= 1. And I have already
> > shown that we see a win with just bulking 2 packets:
> 
> If you can get 2 packets, indeed you win. If you can on average get >1
> over a long period, you still win.
> You have clearly demonstrated you can do that with traffic
> generators (udp or in kernel pktgen). I was more worried about the
> common use case scenario (handwaved as 1-24 TCP streams).
> 
> The key here is: *if you never hit bulking* then the cost is
> _per packet_ for sch_direct_xmit bypass.
> Question is what is that cost for the common case as defined above?
> Can you hit a bulk level >1 on 1-24 TCP streams?
> I would be happy if your answer is *yes*. 

Answer is yes.  It is very easy with simple netperf TCP_STREAM to cause
queueing >1 packet in the qdisc layer.  If tuned (according to my blog,
unloading netfilter etc.) then a single netperf TCP_STREAM will max out
10Gbit/s and cause a standing queue.

I'm monitoring backlog of qdiscs, and I always see >1 backlog, I never
saw a standing queue of 1 packet in my testing.  Either the backlog
area is high 100-200 packets, or 0 backlog.  (With fake pktgen/trafgen
style tests, it's possible to cause 1000 backlog).


> If your answer is no (since
> it is hard to achieve) - then how far off is it from before your
> patches (since now you have added at minimal a branch check).
> I think it is fair for you to quantify that, no?
> Feature is still useful for the other cases.
> 
> Note:
> This is what i referred to as the "no animals were hurt during the
> making of these patches" statement. I am sorry again for raining on
> the parade.

I'm starting to think this patch is the most carefully tested patch on
netdev for a very very long time... I'm getting tired of this testing
going on for so long.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
