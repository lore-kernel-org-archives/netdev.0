From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Qdisc: Measuring Head-of-Line blocking with netperf-wrapper
Date: Wed, 17 Sep 2014 09:39:56 +0200
Message-ID: <20140917093956.1115fd61@redhat.com>
References: <20140915184517.6c5474e5@redhat.com>
	<20140916152221.41811287@redhat.com>
	<1410875959.7106.200.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140916175600.018350fe@redhat.com>
	<1410885016.7106.203.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	Toke =?UTF-8?B?SMO4aWxhbmQtSsO4cmdlbnNl?= =?UTF-8?B?bg==?=
	<toke@toke.dk>, Dave Taht <dave.taht@gmail.com>, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4288 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751716AbaIQHkf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Sep 2014 03:40:35 -0400
In-Reply-To: <1410885016.7106.203.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 16 Sep 2014 09:30:16 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Tue, 2014-09-16 at 17:56 +0200, Jesper Dangaard Brouer wrote:
> > On Tue, 16 Sep 2014 06:59:19 -0700
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > 
> > > With the TCP usec rtt work I did lately, you'll get more precise results
> > > from a TCP_RR flow, as Tom and I explained.
> > 
> > Here you go, developed a new test:
> 
> Just to make sure I understand (sorry I dont have time going all your
> graphs right now)

Summary for you:
1) I have created the TCP_RR latency test you and Tom asked for.

2) Graphs shows TCP_RR and UDP_RR are more accurate than ping

3) Graphs shows that ping is within same range as TCP_RR and UDP_RR

4) My only problem, NoneXSO case does not work with TCP_RR, and
   I need the NoneXSO case for evaluating my qdisc bulking patches.

> The target of your high prio flow is different from target of the
> antagonist flows ?
> 
> Otherwise, you are not only measuring head of line blocking of your
> host, but the whole chain, including scheduling latencies of the
> (shared) target.

For the target-host I'm avoiding the problem, as it receives packets on
different HW queue and netservers will be running on different CPUs.

For the host, I'm by design, forcing it to run on the same single CPU,
to force using the same HW queue, so I can measure this HW queue and
its/BQLs push back. So, yes the host, is also affected by scheduling
latencies, which is bad. (perhaps reason NoneXSO cannot util BW).

How can I construct a test-case, on the host, to solve this problem?
(and still using/measuring the same xmit HW queue)


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
