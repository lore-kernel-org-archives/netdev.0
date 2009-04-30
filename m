From: Radu Rendec <radu.rendec@ines.ro>
Subject: Re: htb parallelism on multi-core platforms
Date: Thu, 30 Apr 2009 14:19:36 +0300
Message-ID: <1241090376.6554.404.camel@blade.ines.ro>
References: <1240495002.6554.155.camel@blade.ines.ro>
	 <20090423181936.GA2756@ami.dom.local>
	 <Pine.LNX.4.64.0904232148120.13815@ask.diku.dk>
	 <1240566136.6554.220.camel@blade.ines.ro>
	 <Pine.LNX.4.64.0904281142270.21301@tyr.diku.dk>
	 <1241000494.6554.307.camel@blade.ines.ro>
	 <Pine.LNX.4.64.0904291225010.23626@tyr.diku.dk>
	 <1241003006.6554.322.camel@blade.ines.ro>
	 <20090429122312.GA2759@ami.dom.local>
	 <1241010951.6554.355.camel@blade.ines.ro>
	 <20090429133810.GB2759@ami.dom.local>
	 <1241022071.6554.375.camel@blade.ines.ro>
	 <395864833.20090430014946@gemenii.ro>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	netdev <netdev@vger.kernel.org>
To: Calin Velea <vcalinus@gemenii.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from NAT-172-Unkn.Local.iNES.RO ([80.86.100.172]:50541 "EHLO
	blade.ines.ro" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751700AbZD3LTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 07:19:44 -0400
In-Reply-To: <395864833.20090430014946@gemenii.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-04-30 at 01:49 +0300, Calin Velea wrote:
>    I tested with e1000 only, on a single quad-core CPU - the L2 cache was
> shared between the cores.
> 
>   For 8 cores I suppose you have 2 quad-core CPUs. If the cores actually
> used belong to different physical CPUs, L2 cache sharing does not occur -
> maybe this could explain the performance drop in your case.
>   Or there may be other explanation...

It is correct, I have 2 quad-core CPUs. If adjacent kernel-identified
CPUs are on the same physical CPU (e.g. CPU0, CPU1, CPU2 and CPU3) - and
it is very probable - then I think the L2 cache was actually shared.
That's because the used CPUs where either 0-3 or 4-7 but never a mix of
them. So perhaps there is another explanation (maybe driver/hardware).

>   It could be the only way to get more power is to increase the number 
> of devices where you are shaping. You could split the IP space into 4 groups
> and direct the trafic to 4 IMQ devices with 4 iptables rules -
> 
> -d 0.0.0.0/2 -j IMQ --todev imq0,
> -d 64.0.0.0/2 -j IMQ --todev imq1, etc...

Yes, but what if let's say 10.0.0.0/24 and 70.0.0.0/24 need to share
bandwidth? 10.a.b.c goes to imq0 qdisc, and 70.x.y.z goes to imq1 qdisc,
and the two qdiscs (HTB sets) are independent. This will result in a
maximum of double the allocated bandwidth (if HTB sets are identical and
traffic is equally distributed).

>   The performance gained through parallelism might be a lot higher than the 
> added overhead of iptables and/or ipset nethash match. Anyway - this is more of
> a "hack" than a clean solution :)
>
> p.s.: latest IMQ at http://www.linuximq.net/ is for 2.6.26 so you will need to try with that

Yes, the performance gained through parallelism is expected to be higher
than the loss of the additional overhead. That's why I asked for
parallel HTB in the first place, but got very disappointed after David
Miller's reply :)

Thanks a lot for all the hints and for the imq link. Imq is very
interesting regardless of whether it proves to be useful for this
project of mine or not.

Radu Rendec


