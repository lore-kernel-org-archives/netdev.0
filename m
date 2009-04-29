From: Radu Rendec <radu.rendec@ines.ro>
Subject: Re: htb parallelism on multi-core platforms
Date: Wed, 29 Apr 2009 14:03:26 +0300
Message-ID: <1241003006.6554.322.camel@blade.ines.ro>
References: <20090423082052.GA4243@ff.dom.local>
	 <1240495002.6554.155.camel@blade.ines.ro>
	 <20090423181936.GA2756@ami.dom.local>
	 <Pine.LNX.4.64.0904232148120.13815@ask.diku.dk>
	 <1240566136.6554.220.camel@blade.ines.ro>
	 <Pine.LNX.4.64.0904281142270.21301@tyr.diku.dk>
	 <1241000494.6554.307.camel@blade.ines.ro>
	 <Pine.LNX.4.64.0904291225010.23626@tyr.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	netdev <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from NAT-172-Unkn.Local.iNES.RO ([80.86.100.172]:41521 "EHLO
	blade.ines.ro" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757365AbZD2LDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 07:03:34 -0400
In-Reply-To: <Pine.LNX.4.64.0904291225010.23626@tyr.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-04-29 at 12:31 +0200, Jesper Dangaard Brouer wrote:
> Just noticed that Jeremy Kerr has made some python scripts to make it even 
> easier to use oprofile.
> See http://ozlabs.org/~jk/diary/tech/linux/hiprofile-v1.0.diary/

Thanks for the hint; I'll have a look at the scripts too.

> I would rather want to see the output from cls_u32.ko
> 
> opreport --symbols -cl cls_u32.ko --image-path=/lib/modules/`uname -r`/kernel/

samples  %        image name               symbol name
-------------------------------------------------------------------------------
38424    100.000  cls_u32.ko               u32_classify
  38424    100.000  cls_u32.ko               u32_classify [self]
-------------------------------------------------------------------------------

Well, this doesn't tell us much more, but I think it's pretty obvious
what cls_u32 is doing :)

> > Am I misinterpreting the results, or does it look like the real problem
> > is actually packet classification?
> 
> Yes, it looks like the problem is your u32 classification setup... Perhaps 
> its not doing what you think its doing...  didn't Jarek provide some hints 
> for you to follow?

I've just realized that I might be hitting the worst-case bucket with
the (ip) destinations I chose for the test traffic. I'll try 

I haven't tried tweaking htb_hysteresis yet (that was one of Jarek's
hints) - it's debatable that it would help since the real problem seems
to be in u32 (not htb), but I'll give it a try anyway.

Another hint was to make sure that "tc class add" goes before
corresponding "tc filter add" - checked: it's ok.

Another interesting hint came from Calin Velea, whose tests suggest that
the overall performance is better with napi turned off, since (rx)
interrupt work is distributed to all cpus/cores. I'll try to replicate
this as soon as I make some small changes to my test setup so that I'm
able to measure overall htb throughput on the egress nic (bps and pps).

Thanks,

Radu Rendec


