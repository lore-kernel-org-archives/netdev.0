From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH RFC] ipv6: use stronger hash for reassembly queue hash
 table
Date: Thu, 14 Mar 2013 10:18:10 +0100
Message-ID: <1363252690.14913.42.camel@localhost>
References: <20130308055718.GA28531@order.stressinduktion.org>
	 <20130308130433.GB28531@order.stressinduktion.org>
	 <1362754386.15793.226.camel@edumazet-glaptop>
	 <20130308150831.GD28531@order.stressinduktion.org>
	 <1362756219.15793.240.camel@edumazet-glaptop>
	 <20130313012715.GE14801@order.stressinduktion.org>
	 <1363152568.13690.35.camel@edumazet-glaptop>
	 <20130314013702.GA4129@order.stressinduktion.org>
	 <1363245040.14913.11.camel@localhost>
	 <20130314072341.GC4129@order.stressinduktion.org>
	 <20130314072839.GD4129@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58059 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751113Ab3CNJSQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Mar 2013 05:18:16 -0400
In-Reply-To: <20130314072839.GD4129@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-14 at 08:28 +0100, Hannes Frederic Sowa wrote:
> On Thu, Mar 14, 2013 at 08:23:41AM +0100, Hannes Frederic Sowa wrote:
> > On Thu, Mar 14, 2013 at 08:10:40AM +0100, Jesper Dangaard Brouer wrote:
> > > On Thu, 2013-03-14 at 02:37 +0100, Hannes Frederic Sowa wrote:
> > > 
> > > > [PATCH net] inet: limit length of fragment queue hash table bucket lists
> > > > 
> > > > This patch introduces a constant limit of the fragment queue hash
> > > > table bucket list lengths. Currently the limit 128 is choosen somewhat
> > > > arbitrary and just ensures that we can fill up the fragment cache with
> > > > empty packets up to the default ip_frag_high_thresh limits. It should
> > > > just protect from list iteration eating considerable amounts of cpu.
> > > > 
> > > > If we reach the maximum length in one hash bucket a warning is printed.
> > > > This is implemented on the caller side of inet_frag_find to distinguish
> > > > between the different users of inet_fragment.c.
> > > 
> > > I like the idea of having a safe guard on the fragment queue hash table
> > > bucket list lengths.  But I'm considering another cleanup/evictor
> > > strategy, where we drop the LRU list, and do frag eviction on a hash
> > > bucket level (which will be more cache optimal).  This strategy would
> > > also involve a list length limit.
> > 
> > I would try to get a simple guard into v3.9. In 3.9 the hashing of the key
> > of ipv6 fragments changed in such a way that an attacker could generate
> > fragments which would end up in just one hash chain, thus eating a lot
> > of cpu time because of list traversal. Later on, when you post your
> > patches we could simply revert/update this safeguard to your version.
> 
> I just wanted to mention that if you plan to target v3.9 with some patches we
> could simply drop this patch.

I will start working on this as soon as Netfilter Workshop is over and I
have recovered from organizing this event.  DaveM told me I needed to
finish my frag patches first, before I could implement all the other
cool ideas we have come up with during the workshop ;-)

But I don't know if my frag changes can make v3.9, maybe v3.10 is more
realistic?  In which case we should use your patch to close this problem
on v3.9 IMHO.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
