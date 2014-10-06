From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] qdisc: validate skb without holding lock
Date: Mon, 6 Oct 2014 16:12:35 +0200
Message-ID: <20141006161235.010033f5@redhat.com>
References: <20141003.145647.1980640682969765484.davem@davemloft.net>
	<1412373477.17245.5.camel@edumazet-glaptop2.roam.corp.google.com>
	<1412375467.17245.16.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141003.153645.72976986956341944.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	therbert@google.com, hannes@stressinduktion.org, fw@strlen.de,
	dborkman@redhat.com, jhs@mojatatu.com, alexander.duyck@gmail.com,
	john.r.fastabend@intel.com, dave.taht@gmail.com, toke@toke.dk,
	brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2417 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752680AbaJFOND (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Oct 2014 10:13:03 -0400
In-Reply-To: <20141003.153645.72976986956341944.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 03 Oct 2014 15:36:45 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 03 Oct 2014 15:31:07 -0700
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Validation of skb can be pretty expensive :
> > 
> > GSO segmentation and/or checksum computations.
> > 
> > We can do this without holding qdisc lock, so that other cpus
> > can queue additional packets.
> > 
[...]
> > 
> > Turning TSO on or off had no effect on throughput, only few more cpu
> > cycles. Lock contention on qdisc lock disappeared.

This is good work! Lock contention significantly reduced!

My 10G tests just 2x 10G netperf TCP_STREAM shows:

 With GSO=off TSO=off, _raw_spin_lock is now only at perf top#13 with
1.44% (80% from qdisc calls, 60% is from __dev_queue_xmit and 20% from
sch_direct_xmit) (before with qdisc bulking is was 2.66%).

 The "show off" case is GSO=on TSO=off, where raw_spin_lock is now only
at perf top#26 with 0.85% and only 54.74% comes from qdisc calls
(52.07% sch_direct_xmit and 2.67% __dev_queue_xmit).


This is some significant improvements to the kernels xmit layer,
me very happy!!! :-))) Thanks everyone!

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
