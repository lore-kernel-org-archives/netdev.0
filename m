From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: htb parallelism on multi-core platforms
Date: Thu, 30 Apr 2009 13:44:53 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0904301333150.26466@tyr.diku.dk>
References: <1240495002.6554.155.camel@blade.ines.ro>  <20090423181936.GA2756@ami.dom.local>
  <Pine.LNX.4.64.0904232148120.13815@ask.diku.dk>  <1240566136.6554.220.camel@blade.ines.ro>
  <Pine.LNX.4.64.0904281142270.21301@tyr.diku.dk>  <1241000494.6554.307.camel@blade.ines.ro>
  <Pine.LNX.4.64.0904291225010.23626@tyr.diku.dk>  <1241003006.6554.322.camel@blade.ines.ro>
  <20090429122312.GA2759@ami.dom.local>  <1241010951.6554.355.camel@blade.ines.ro>
  <20090429133810.GB2759@ami.dom.local>  <1241022071.6554.375.camel@blade.ines.ro>
  <395864833.20090430014946@gemenii.ro> <1241090376.6554.404.camel@blade.ines.ro>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Calin Velea <vcalinus@gemenii.ro>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	netdev <netdev@vger.kernel.org>
To: Radu Rendec <radu.rendec@ines.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:44373 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752791AbZD3Loz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2009 07:44:55 -0400
In-Reply-To: <1241090376.6554.404.camel@blade.ines.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 30 Apr 2009, Radu Rendec wrote:

> On Thu, 2009-04-30 at 01:49 +0300, Calin Velea wrote:
>>    I tested with e1000 only, on a single quad-core CPU - the L2 cache was
>> shared between the cores.
>>
>>   For 8 cores I suppose you have 2 quad-core CPUs. If the cores actually
>> used belong to different physical CPUs, L2 cache sharing does not occur -
>> maybe this could explain the performance drop in your case.
>>   Or there may be other explanation...
>
> It is correct, I have 2 quad-core CPUs. If adjacent kernel-identified
> CPUs are on the same physical CPU (e.g. CPU0, CPU1, CPU2 and CPU3) - and
> it is very probable - then I think the L2 cache was actually shared.
> That's because the used CPUs where either 0-3 or 4-7 but never a mix of
> them. So perhaps there is another explanation (maybe driver/hardware).

WRONG assumption regarding CPU id's

Look in /proc/cpuinfo for the correct answer.

(From a:
  model name      : Intel(R) Xeon(R) CPU           E5420  @ 2.50GHz)

cat /proc/cpuinfo | egrep -e '(processor|physical id|core id)'
processor       : 0
physical id     : 0
core id         : 0

processor       : 1
physical id     : 1
core id         : 0

processor       : 2
physical id     : 0
core id         : 2

processor       : 3
physical id     : 1
core id         : 2

processor       : 4
physical id     : 0
core id         : 1

processor       : 5
physical id     : 1
core id         : 1

processor       : 6
physical id     : 0
core id         : 3

processor       : 7
physical id     : 1
core id         : 3

E.g. Here CPU0 and CPU4 is sharing the same L2 cache.


Hilsen
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
