From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: qdisc running
Date: Mon, 20 Oct 2014 18:17:56 +0200
Message-ID: <20141020181756.2c8f33b9@redhat.com>
References: <54440FFA.40307@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: john Fastabend <john.r.fastabend@intel.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	eric Dumazet <edumazet@google.com>, brouer@redhat.com,
	Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27866 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751181AbaJTQSR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Oct 2014 12:18:17 -0400
In-Reply-To: <54440FFA.40307@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sun, 19 Oct 2014 15:24:42 -0400 Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> Jesper,
> 
> You asked at the meeting the point to qdisc running.

Talking about __QDISC___STATE_RUNNING see slide 9/16:
 http://people.netfilter.org/hawk/presentations/LinuxPlumbers2014/performance_tx_qdisc_bulk_LPC2014.pdf

> Original intent is to allow only one cpu to enter the lower half of the
> qdisc path. IOW, if one cpu was already in the qdisc then that guy
> could be used to dequeue packets. i.e this is good for batching.
> Original idea was Herbert's with major improvement from Eric
> and a small one from me.

I guess it is good for our recent dequeue batching. But I think/hope we
can come up with a scheme that does not requires 6 lock/unlock
operations (as illustrated on slide 9).

John and I have talked about doing a lockless qdisc, but maintaining
this __QDISC___STATE_RUNNING in a lockless scenario, would cost us
extra atomic ops...

Are we still sure, that this model of only allowing a single CPU in the
dequeue path, is still the best solution?  (The TXQ lock should already
protect several CPUs in this code path).


> For history of different tried approaches look at:
> Look at slide 2: 
> http://vger.kernel.org/netconf2011_slides/jamal_netconf2011.pdf

I can see that you really needed the budget/fairness in the dequeue
loop, that we recently mangled with.

> then download the **amazing** flash animations which describe
> that history.
> http://vger.kernel.org/netconf2011_slides/netconf-2011-flash.tgz
> 
> Follow the bullets in slide2 and map to the flash animations.

What tool do I use to play these SWF files? (I tried VLC but no luck).

> If you go over them, you'll see it is still needed.

Too bad, I would like to avoid the second 
 
> I think someone oughta put those **amazing** animations on some
> website;->

I hope someone else can pick that up ;-)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
