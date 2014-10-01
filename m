From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH V5] qdisc: bulk dequeue support for qdiscs with
 TCQ_F_ONETXQUEUE
Date: Wed, 1 Oct 2014 22:32:29 +0200
Message-ID: <20141001223229.6cbaac07@redhat.com>
References: <20140930085114.24043.81310.stgit@dragon>
	<542A8EF9.10403@mojatatu.com>
	<20140930.142038.235338672810639160.davem@davemloft.net>
	<542BFEF3.7020302@mojatatu.com>
	<CA+mtBx8rVu9FXtnc18n22L9LP=t=3Pso7U2yvvLcnny57w8aXg@mail.gmail.com>
	<542C1F1F.90404@mojatatu.com>
	<20141001192840.5679a671@redhat.com>
	<542C4E0D.4050404@mojatatu.com>
	<20141001214700.18b16387@redhat.com>
	<542C5E8B.7070204@mojatatu.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:9190 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751208AbaJAUcw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2014 16:32:52 -0400
In-Reply-To: <542C5E8B.7070204@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 01 Oct 2014 16:05:31 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> On 10/01/14 15:47, Jesper Dangaard Brouer wrote:
> 
> >
> > Answer is yes.  It is very easy with simple netperf TCP_STREAM to cause
> > queueing >1 packet in the qdisc layer.
> 
> If that is the case, I withdraw any doubts i had.
> Can you please specify this in your commit logs for patch 0?

I'll try to make it more explicit.
Will resubmit patchset shortly...

Notice it is not difficult cause a queue to form, but it is tricky (not
difficult) to correctly test this patchset.  Perhaps you misread my
statement earlier as "it was difficult to test and cause a queue to form"?


> > If tuned (according to my blog,
> > unloading netfilter etc.) then a single netperf TCP_STREAM will max out
> > 10Gbit/s and cause a standing queue.
> >
> 
> You should describe such tuning in the patch log (hard to read
> blogs for more than 30 seconds; write a paper if you want to provide
> more details).

I think you could read this blog in 30 sec:
 http://netoptimizer.blogspot.dk/2014/04/basic-tuning-for-network-overload.html

My cover letter and testing section... will take you longer that 30
sec, it have grown quite large (and Eric will not even read it :-P ;-))

Believe or not, I've actually restricted and reduced the testing
section.  If you want the hole verbose version of my testing for the
upcoming V6 patch, look at this:

 http://people.netfilter.org/hawk/qdisc/measure12_internal_V6_patch/
 http://people.netfilter.org/hawk/qdisc/measure13_V6_patch_NObulk/

And use netperf-wrapper to dive into the data.
A quick setup guide:
 http://netoptimizer.blogspot.dk/2014/09/mini-tutorial-for-netperf-wrapper-setup.html


> > I'm monitoring backlog of qdiscs, and I always see >1 backlog, I never
> > saw a standing queue of 1 packet in my testing.  Either the backlog
> > area is high 100-200 packets, or 0 backlog.  (With fake pktgen/trafgen
> > style tests, it's possible to cause 1000 backlog).
> 
> It would be nice to actually collect such stats. Monitoring the backlog
> via dumping qdisc stats is a good start - but actually keeping traces
> of average bulk size is more useful.

I usually also monitors the BQL limits during these tests.

 grep -H . /sys/class/net/eth4/queues/tx-*/byte_queue_limits/{inflight,limit}

To Toke:
 Perhaps we could convince Toke, to add a netperf-wrapper recorder for
the BQL inflight and limit?  (It would be really cool to plot together)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
