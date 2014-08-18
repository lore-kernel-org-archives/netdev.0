From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: Performance regression on kernels 3.10 and newer
Date: Mon, 18 Aug 2014 08:22:32 -0700
Message-ID: <53F21A38.50905@intel.com>
References: <53ECFDAB.5010701@intel.com>	<1408041962.6804.31.camel@edumazet-glaptop2.roam.corp.google.com>	<53ED4354.9090904@intel.com>	<20140814.162024.2218312002979492106.davem@davemloft.net>	<53EE4023.6080902@intel.com>	<CA+mtBx_aEe6SvWV6tfqzGWcPvVM+FE6kbnyFE5FbECU9HN7EXg@mail.gmail.com>	<53EE5B25.3040206@intel.com> <CA+mtBx-LZgnpWAf3Jn0htoga32UaMc-NAqURmXezmZmwg2oGRQ@mail.gmail.com> <53EE967F.9090101@intel.com> <063D6719AE5E284EB5DD2968C1650D6D1747969E@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Rick Jones <rick.jones2@hp.com>
To: David Laight <David.Laight@ACULAB.COM>,
	Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:13080 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750789AbaHRPWt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Aug 2014 11:22:49 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1747969E@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/18/2014 02:03 AM, David Laight wrote:
> From: Alexander Duyck
>> ...
>> Another test I tried was to hack the nettest_bsd.c file in netperf to
>> perform a poll() based receive.  That resolved the issue and had all the
>> performance of the tcp_low_latency case.  I may see if I can work with
>> Rick to push something like that into netperf as I really would prefer
>> to avoid having to advise everyone on how to setup the sysctl for
>> tcp_low_latency.
> 
> Doesn't that generate 2 system calls per receive?
> Unless it now returns more data per receive I'm surprised that
> it actually faster.

If you haven't been keeping up with the thread what I am gaining by
doing this is avoiding a significant cache thrash issue with the dst
entry as the prequeue path involves updating the reference count that is
shared by all of my CPUs.

By using poll to wait for it I don't load frames onto the TCP prequeue
and thereby avoid it.

> OTOH I've some code that runs a lot better when I run while :; do :; done
> for all but one of the cpus.
> I think that is because the processes spinning in userspace don't
> get pre-empted.
> 
> 	David
> 

What you are probably seeing is that the CPU doesn't go into a deep
sleep state so it likely runs better.  You might try the same thing with
a kernel booted with idle=poll and you would probably see the same result.

Thanks,

Alex
