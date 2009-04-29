From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: htb parallelism on multi-core platforms
Date: Wed, 29 Apr 2009 14:23:12 +0200
Message-ID: <20090429122312.GA2759@ami.dom.local>
References: <20090423082052.GA4243@ff.dom.local> <1240495002.6554.155.camel@blade.ines.ro> <20090423181936.GA2756@ami.dom.local> <Pine.LNX.4.64.0904232148120.13815@ask.diku.dk> <1240566136.6554.220.camel@blade.ines.ro> <Pine.LNX.4.64.0904281142270.21301@tyr.diku.dk> <1241000494.6554.307.camel@blade.ines.ro> <Pine.LNX.4.64.0904291225010.23626@tyr.diku.dk> <1241003006.6554.322.camel@blade.ines.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	netdev <netdev@vger.kernel.org>,
	Calin Velea <calin.velea@gemenii.ro>
To: Radu Rendec <radu.rendec@ines.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f163.google.com ([209.85.218.163]:44439 "EHLO
	mail-bw0-f163.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbZD2MXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 08:23:38 -0400
Received: by bwz7 with SMTP id 7so1130260bwz.37
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2009 05:23:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1241003006.6554.322.camel@blade.ines.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 29, 2009 at 02:03:26PM +0300, Radu Rendec wrote:
> On Wed, 2009-04-29 at 12:31 +0200, Jesper Dangaard Brouer wrote:
...
> > Yes, it looks like the problem is your u32 classification setup... Perhaps 
> > its not doing what you think its doing...  didn't Jarek provide some hints 
> > for you to follow?
> 
> I've just realized that I might be hitting the worst-case bucket with
> the (ip) destinations I chose for the test traffic. I'll try 
> 
> I haven't tried tweaking htb_hysteresis yet (that was one of Jarek's
> hints) - it's debatable that it would help since the real problem seems
> to be in u32 (not htb), but I'll give it a try anyway.

According to the author's(?) comment with hysteresis "The speed gain
is about 1/6", so not very much here considering htb_dequeue time.

> Another hint was to make sure that "tc class add" goes before
> corresponding "tc filter add" - checked: it's ok.
> 
> Another interesting hint came from Calin Velea, whose tests suggest that
> the overall performance is better with napi turned off, since (rx)
> interrupt work is distributed to all cpus/cores. I'll try to replicate
> this as soon as I make some small changes to my test setup so that I'm
> able to measure overall htb throughput on the egress nic (bps and pps).

Radu, since not only your worst case, but also the real case u32
lookups are very big I think you should mainly have a look at Calin's
u32 hash generator or at least his method, and only after optimizing
it try these other tricks. Btw. I hope Calin made this nice program
known to networking/admins lists too.

Btw. #2: I think you wrote you didn't use iptables...

Cheers,
Jarek P.
