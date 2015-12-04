From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [BUG] net: performance regression on ixgbe (Intel 82599EB
 10-Gigabit NIC)
Date: Fri, 4 Dec 2015 10:13:43 -0800
Message-ID: <5661D7D7.4020401@hpe.com>
References: <20151203162627.GA8989@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jirka Hladky <jhladky@redhat.com>,
	Adam Okuliar <aokuliar@redhat.com>,
	Kamil Kolakowski <kkolakow@redhat.com>
To: Otto Sabart <osabart@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t5009.houston.hp.com ([15.240.92.67]:45255 "EHLO
	g9t5009.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754491AbbLDSNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2015 13:13:45 -0500
In-Reply-To: <20151203162627.GA8989@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/2015 08:26 AM, Otto Sabart wrote:
> Hello netdev,
> I probably found a performance regression on ixgbe (Intel 82599EB
> 10-Gigabit NIC) on v4.4-rc3. I am able to see this problem since
> v4.4-rc1.
>
> The bug report you can find here [0].
>
> Can somebody take a look at it?
>
> [0] https://bugzilla.redhat.com/show_bug.cgi?id=1288124

A few of comments/questions  based on reading that bug report:

*)  It is good to be binding netperf and netserver - helps with 
reproducibility, but why the two -T options?  A brief look at 
src/netsh.c suggests it will indeed set the two binding options 
separately but that is merely a side-effect of how I wrote the code.  It 
wasn't an intentional thing.

*) Is irqbalance disabled and the IRQs set the same each time, or might 
there be variability possible there?  Each of the five netperf runs will 
be a different four-tuple which means each may (or may not) get RSS 
hashed/etc differently.

*) It is perhaps adding duct tape to already-present belt and 
suspenders, but is power-management set to a fixed state on the systems 
involved? (Since this seems to be ProLiant G7s going by the legends on 
the charts, either static high perf or static low power I would imagine)

*) What is the difference before/after for the service demands?  The 
netperf tests being run are asking for CPU utilization but I don't see 
the service demand change being summarized.

*) Does a specific CPU on one side or the other saturate? 
(LOCAL_CPU_PEAK_UTIL, LOCAL_CPU_PEAK_ID, REMOTE_CPU_PEAK_UTIL, 
REMOTE_CPU_PEAK_ID output selectors)

*) What are the processors involved?  Presumably the "other system" is 
fixed?

*) It is important to remember the socket buffer sizes reported with the 
default output is *just* what they were when the data socket was 
created.  If you want to see what they became by the end of the test, 
you need to use the appropriate output selectors (or, IIRC invoking the 
tests as "omni" rather than tcp_stream/tcp_maerts will report the end 
values rather than the start ones.).

happy benchmarking,

rick jones
