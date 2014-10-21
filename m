From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Queue with wait-free enqueue, blocking dequeue, splice
Date: Tue, 21 Oct 2014 13:48:02 +0200
Message-ID: <20141021134802.05104ecd@redhat.com>
References: <1311316954.11157.1413631325000.JavaMail.zimbra@efficios.com>
	<412768308.11171.1413632892841.JavaMail.zimbra@efficios.com>
	<20141020160237.302aa17c@redhat.com>
	<285747581.12566.1413849850921.JavaMail.zimbra@efficios.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	brouer@redhat.com
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7269 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755167AbaJULtQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2014 07:49:16 -0400
In-Reply-To: <285747581.12566.1413849850921.JavaMail.zimbra@efficios.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Oct 2014 00:04:10 +0000 (UTC) Mathieu Desnoyers <mathieu.desnoyers@efficios.com> wrote:
> > From: "Jesper Dangaard Brouer" <brouer@redhat.com>
> > 
[...]
> > I can certainly use the wfcq_empty() check,
> 
> Not sure why you would want to use it, considering that the dequeue
> operation implies it. If there is nothing to dequeue, we just return
> immediately. Dequeue operation does not block on empty queue. It
> just busy waits if it happen to see the queue in an intermediate
> state of the enqueue operation (which is very short, few instructions
> at most, with preemption disabled).
> 
> > but I guess I need to
> > maintain a separate counter to maintain the qdisc limit, right?
> > (I would use the approximate/split counter API percpu_counter to keep
> > this scalable, and wfcq_empty() would provide an accurate empty check)
> 
> Yes for split counters, not sure why you need the empty check explicitly
> in your use-case though.

In case the qdisc is empty, we avoid/bypass the enqueue + dequeue phase
and instead transmit the packet directly.

Iif the flag TCQ_F_CAN_BYPASS is set. 
 https://github.com/torvalds/linux/blob/master/net/core/dev.c#L2799
But I'm not 100% sure that we can set this flag on a lock-less qdisc.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
