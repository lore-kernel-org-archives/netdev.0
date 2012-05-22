From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] tc_codel: Controlled Delay AQM
Date: Tue, 22 May 2012 14:16:10 -0700
Message-ID: <20120522141610.601f68ed@nehalam.linuxnetplumber.net>
References: <1336717355.31653.130.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Dave Taht <dave.taht@bufferbloat.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43931 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751570Ab2EVVQP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2012 17:16:15 -0400
In-Reply-To: <1336717355.31653.130.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 May 2012 08:22:35 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> An implementation of CoDel AQM, from Kathleen Nichols and Van Jacobson. 
> 
> http://queue.acm.org/detail.cfm?id=2209336 
> 
> This AQM main input is no longer queue size in bytes or packets, but the
> delay packets stay in (FIFO) queue.
> 
> As we don't have infinite memory, we still can drop packets in enqueue()
> in case of massive load, but mean of CoDel is to drop packets in
> dequeue(), using a control law based on two simple parameters :
> 
> target : target sojourn time (default 5ms)
> interval : width of moving time window (default 100ms)
> 
> Selected packets are dropped, unless ECN is enabled and packets can get
> ECN mark instead.
> 
> Usage: tc qdisc ... codel [ limit PACKETS ] [ target TIME ]
>                           [ interval TIME ] [ ecn ]
> 
> qdisc codel 10: parent 1:1 limit 2000p target 3.0ms interval 60.0ms ecn 
>  Sent 13347099587 bytes 8815805 pkt (dropped 0, overlimits 0 requeues 0) 
>  rate 202365Kbit 16708pps backlog 113550b 75p requeues 0 
>   count 116 lastcount 98 ldelay 4.3ms dropping drop_next 816us
>   maxpacket 1514 ecn_mark 84399 drop_overlimit 0
> 
> CoDel must be seen as a base module, and should be used keeping in mind
> there is still a FIFO queue. So a typical setup will probably need a
> hierarchy of several qdiscs and packet classifiers to be able to meet
> whatever constraints a user might have.
> 
> One possible example would be to use fq_codel, which combines Fair
> Queueing and CoDel, in replacement of sfq / sfq_red.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Dave Taht <dave.taht@bufferbloat.net>
> ---
> Notes :
> 1) : Dave Taht will send a nice man-page for this stuff.
> 2) : the TCA_NETEM_ECN bit is because of include/linux/pkt_sched.h sync
> with net-next
>      (I'll send a separate patch for netem)
> 

Applied. Used 3.5 sanitized header (not the one in your patch),
and fixed whitespace error.


Ok, where's the man page :-)
