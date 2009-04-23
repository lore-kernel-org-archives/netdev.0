From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: htb parallelism on multi-core platforms
Date: Thu, 23 Apr 2009 08:20:52 +0000
Message-ID: <20090423082052.GA4243@ff.dom.local>
References: <Pine.LNX.4.64.0904222313080.22266@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Radu Rendec <radu.rendec@ines.ro>,
	Denys Fedoryschenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:45437 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754047AbZDWIVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 04:21:03 -0400
Received: by wf-out-1314.google.com with SMTP id 26so364422wfd.4
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2009 01:21:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0904222313080.22266@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22-04-2009 23:29, Jesper Dangaard Brouer wrote:
> On Wed, 22 Apr 2009, Radu Rendec wrote:
> 
>> Thanks for the hints! As far as I understand, HFSC is also implemented
>> as a queue discipline (like HTB), so I guess it suffers from the same
>> design limitations (doesn't span across multiple CPUs). Is this
>> assumption correct?
> 
> Yes.

Within a common tree of classes it would a need finer locking to
separate some jobs but considering cache problems I doubt there would
be much gain from such redesigning for smp. On the other hand, a
common tree is necessary if these classes really have to share every
byte, which I doubt. Then we could think of config and maybe tiny
hardware "redesign" (to more qdiscs/roots). So, e.g. using additional
(cheap) NICs and even switch, if possible, looks quite natural way of
spanning. Similar thing (multiple htb qdiscs) should be possible in
the future with one multiqueue NIC too.

There is also an interesting thread "Software receive packet steering"
nearby, but using this for shaping only looks like "less simple":
http://lwn.net/Articles/328339/

> 
>> As for htb_hysteresis I actually haven't tried it. Although it is
>> definitely worth a try (especially if the average traffic grows), I
>> don't think it can compensate multithreading / parallel execution.
> 
> Its runtime adjustable, so its easy to try out.
> 
>   via /sys/module/sch_htb/parameters/htb_hysteresis
> 
> 
>> At least half of a packet processing time is consumed by classification 
>> (although I am using hashes).
> 
> The HTB classify hash has a scalability issue in kernels below 2.6.26. 
> Patrick McHardy fixes that up in 2.6.26.  What kernel version are you 
> using?
> 
> Could you explain how you do classification? And perhaps outline where you 
> possible scalability issue is located?

BTW, I hope you add filters after classes they point to.

Jarek P.
