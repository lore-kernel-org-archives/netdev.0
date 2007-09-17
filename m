From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC][NET_SCHED] explict hold dev tx lock
Date: Mon, 17 Sep 2007 17:58:51 +0400
Message-ID: <20070917135850.GA19380@2ka.mipt.ru>
References: <1189959274.4241.30.camel@localhost> <20070916.123158.92582301.davem@davemloft.net> <1189975284.4230.14.camel@localhost> <1189975939.4230.19.camel@localhost> <1189977000.4230.25.camel@localhost> <20070917102738.GA3087@2ka.mipt.ru> <1190034238.4230.113.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, kaber@trash.net, dada1@cosmosbay.com
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:39312 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753875AbXIQN7o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2007 09:59:44 -0400
Content-Disposition: inline
In-Reply-To: <1190034238.4230.113.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 17, 2007 at 09:03:58AM -0400, jamal (hadi@cyberus.ca) wrote:
> > Did I understand you right, that you replaced trylock with lock and
> > thus removed collision handling and got better results?
> 
> Yes, a small one with the 4 CPUs and no irq binding. Note that in the
> test cases i run, the contention for queue lock was high (since all CPUs
> were busy processing traffic). 
> I think as the the number of CPUs go up, this will become more
> prominent. The choice is between contending for queue lock or this lock.
> One lock is contended by max of two cpus, the other by N cpus. As N goes
> up, you want to have more mercy on the one that is contended by N cpus.
> Did that make sense?

I think if number of cpus grows and there is no interupt binding, system
will not scale very well anyway, but your description makes sense,
thanks.

-- 
	Evgeniy Polyakov
