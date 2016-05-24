From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] net: remove busylock
Date: Tue, 24 May 2016 07:37:26 -0700
Message-ID: <1464100646.5939.50.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1463677716.18194.203.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAKgT0UfBxW=KpqJux+tjyNpHQUHhZ5Laiqnt5FPs=jpkBJWrHA@mail.gmail.com>
	 <20160520092903.38620c60@redhat.com>
	 <1463749909.18194.291.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1463752069.18194.294.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1463753815.18194.298.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160520194951.6354fba1@redhat.com>
	 <063D6719AE5E284EB5DD2968C1650D6D5F4C5166@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Jesper Dangaard Brouer' <brouer@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Alexander Duyck <aduyck@mirantis.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35345 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754233AbcEXOh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2016 10:37:28 -0400
Received: by mail-pa0-f54.google.com with SMTP id tb2so7370242pac.2
        for <netdev@vger.kernel.org>; Tue, 24 May 2016 07:37:28 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D5F4C5166@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-05-24 at 13:50 +0000, David Laight wrote:
> From: Jesper Dangaard Brouer
> > Sent: 20 May 2016 18:50
> ...
> > If would be cool if you could run a test with removed busylock and
> > allow HTB to bulk dequeue.
> 
> (Without having looked ....)
> Could you have two queues and separate queue and dequeue locks.
> 
> The enqueue code would acquire the enqueue lock and add the packet
> to the first queue.
> 
> The dequeue code would acquire the dequeue lock and try to remove
> a packet from the 2nd queue, if nothing present it would acquire
> the enqueue lock and move the entire 1st queue to the 2nd queue.
> 
> The obvious downside is two lock/unlocks for single packet dequeue.
> If you can guarantee a single dequeue thread the 2nd lock isn't needed.
> 

Not with HTB or any 'complex' qdisc hierarchy, where we have many
'queues' and strict limits (packets per qdisc)
