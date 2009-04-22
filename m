From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: htb parallelism on multi-core platforms
Date: Wed, 22 Apr 2009 23:29:32 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0904222313080.22266@ask.diku.dk>
References: <1239964844.21569.57.camel@blade.ines.ro>  <49E905A2.7040402@gmail.com>
 <200904180321.50281.denys@visp.net.lb>  <20090418075637.GA2738@ami.dom.local>
 <1240408926.6554.57.camel@blade.ines.ro>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Denys Fedoryschenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: Radu Rendec <radu.rendec@ines.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:57766 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753706AbZDVV3i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Apr 2009 17:29:38 -0400
In-Reply-To: <1240408926.6554.57.camel@blade.ines.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Apr 2009, Radu Rendec wrote:

> Thanks for the hints! As far as I understand, HFSC is also implemented
> as a queue discipline (like HTB), so I guess it suffers from the same
> design limitations (doesn't span across multiple CPUs). Is this
> assumption correct?

Yes.

> As for htb_hysteresis I actually haven't tried it. Although it is
> definitely worth a try (especially if the average traffic grows), I
> don't think it can compensate multithreading / parallel execution.

Its runtime adjustable, so its easy to try out.

  via /sys/module/sch_htb/parameters/htb_hysteresis


> At least half of a packet processing time is consumed by classification 
> (although I am using hashes).

The HTB classify hash has a scalability issue in kernels below 2.6.26. 
Patrick McHardy fixes that up in 2.6.26.  What kernel version are you 
using?

Could you explain how you do classification? And perhaps outline where you 
possible scalability issue is located?

If you are interested how I do scalable classification, see my 
presentation from Netfilter Workshop 2008:

  http://nfws.inl.fr/en/?p=115
  http://www.netoptimizer.dk/presentations/nfsw2008/Jesper-Brouer_Large-iptables-rulesets.pdf


> I guess htb_hysteresis only affects the actual shaping (which takes 
> place after the packet is classified).

Yes, htb_hysteresis basically is a hack to allow extra bursts... we 
actually considered removing it completely...

Hilsen
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
