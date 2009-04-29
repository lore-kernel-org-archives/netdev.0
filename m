From: Calin Velea <calin.velea@gemenii.ro>
Subject: Re[2]: htb parallelism on multi-core platforms
Date: Thu, 30 Apr 2009 02:00:53 +0300
Message-ID: <457095732.20090430020053@gemenii.ro>
References: <1240495002.6554.155.camel@blade.ines.ro> <20090423181936.GA2756@ami.dom.local> <Pine.LNX.4.64.0904232148120.13815@ask.diku.dk> <1240566136.6554.220.camel@blade.ines.ro> <Pine.LNX.4.64.0904281142270.21301@tyr.diku.dk> <1241000494.6554.307.camel@blade.ines.ro> <Pine.LNX.4.64.0904291225010.23626@tyr.diku.dk> <1241003006.6554.322.camel@blade.ines.ro> <20090429122312.GA2759@ami.dom.local> <1241010951.6554.355.camel@blade.ines.ro> <20090429133810.GB2759@ami.dom.local> <1241022071.6554.375.camel@blade.ines.ro> <395864833.20090430014946@gemenii.ro>
Reply-To: Calin Velea <vcalinus@gemenii.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Radu Rendec <radu.rendec@ines.ro>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	netdev <netdev@vger.kernel.org>
To: Calin Velea <vcalinus@gemenii.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gemenii.ro ([195.28.184.8]:56908 "EHLO newmail.gemenii.ro"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752374AbZD2XB3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Apr 2009 19:01:29 -0400
In-Reply-To: <395864833.20090430014946@gemenii.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Calin,

Thursday, April 30, 2009, 1:49:46 AM, you wrote:

> Wednesday, April 29, 2009, 7:21:11 PM, you wrote:

>> I finally managed to disable NAPI on e1000e - apparently it can only be
>> done on the "official" Intel driver (downloaded from their website), by
>> compiling with "make CFLAGS_EXTRA=-DE1000E_NO_NAPI". This doesn't seem
>> to be available in the (2.6.29) kernel driver.

>> With NAPI disabled, 4 (of 8) cores go to 100% (instead of only one), but
>> overall throughput *decreases* from ~110K pps (with NAPI) to ~80K pps.
>> This makes sense, since h/w interrupt is much more time consuming than
>> polling (that's the whole idea behind NAPI anyway).

>> Radu Rendec

>    I tested with e1000 only, on a single quad-core CPU - the L2 cache was
> shared between the cores.

>   For 8 cores I suppose you have 2 quad-core CPUs. If the cores actually
> used belong to different physical CPUs, L2 cache sharing does not occur -
> maybe this could explain the performance drop in your case.
>   Or there may be other explanation...


>   Anyway - coming back to David Miller's words:

> "HTB acts upon global state, so anything that goes into a particular 
> device's HTB ruleset is going to be single threaded. 
> There really isn't any way around this. "

>   It could be the only way to get more power is to increase the number
> of devices where you are shaping. You could split the IP space into 4 groups
> and direct the trafic to 4 IMQ devices with 4 iptables rules -

> -d 0.0.0.0/2 -j IMQ --todev imq0,
> -d 64.0.0.0/2 -j IMQ --todev imq1, etc...

> Or you can customize the split depeding on the traffic distribution.
> ipset nethash match can also be used.


>  The 4 devices can have the same htb ruleset, only the right parts 
> of it will match.
>   You should test with 4 flows that use all the devices simultaneously and
> see what is the aggregate throughput.


>   The performance gained through parallelism might be a lot higher than the
> added overhead of iptables and/or ipset nethash match. Anyway - this is more of
> a "hack" than a clean solution :)


> p.s.: latest IMQ at http://www.linuximq.net/ is for 2.6.26 so you will need to try with that


  You will also need -i ethX (router), or -m physdev --physdev-in ethX
(bridge) to differentiate between upload and download in the iptables rules.


-- 
Best regards,
 Calin                            mailto:calin.velea@gemenii.ro

