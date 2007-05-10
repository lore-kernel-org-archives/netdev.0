From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] sched: Optimize return value of qdisc_restart
Date: Thu, 10 May 2007 10:12:55 -0400
Message-ID: <1178806376.4074.90.camel@localhost>
References: <E1Hm8Ey-0006oe-00@gondolin.me.apana.org.au>
	 <1178803084.4074.48.camel@localhost>
	 <20070510135220.GA26655@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, krkumar2@in.ibm.com, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>, Roberto Nibali <ratz@drugphish.ch>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.225]:34218 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753508AbXEJONA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 10:13:00 -0400
Received: by wx-out-0506.google.com with SMTP id h31so550272wxd
        for <netdev@vger.kernel.org>; Thu, 10 May 2007 07:13:00 -0700 (PDT)
In-Reply-To: <20070510135220.GA26655@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-10-05 at 23:52 +1000, Herbert Xu wrote:
> On Thu, May 10, 2007 at 09:18:04AM -0400, jamal wrote:
> > 
> > I wonder how much performance improvement this give now that the extra
> > incursion into qdisc_restart is avoided.
> 
> Probably very little since the only way it can make a difference is if
> there is lots of contention.  But if there is lots of contention we
> should stay in the function anyway.

Less to do with CPU contention and more with Krishna's change which
avoids entering that region all together which is useful even in the
absence of contention. In the past (based on some measurement i did)
upto 50% of the executions of qdisc restart were on an empty queue
depending on traffic rates.

BTW, given that i couldnt recall the layout of the locks on qdisc
restart; I think i will come back with the old patch i had to clean up
the readability of qdisc restart so it is easy to tell just by quick
inspection.

Since Canada seems to be comfortably taking revenge on the Swiss (my
condolonces to Thomas and Ratz) - i think it is time for me to head
out ;-> ttl.

cheers,
jamal 

