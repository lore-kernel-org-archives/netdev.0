From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] iptables: lock free counters
Date: Fri, 20 Feb 2009 14:57:21 -0800
Message-ID: <499F3551.5@hp.com>
References: <20090218051906.174295181@vyatta.com>	<20090218052747.321329022@vyatta.com>	<20090219114719.560999b5@extreme>	<499DEF49.3040602@cosmosbay.com>	<499DF1A2.1030405@hp.com>	<20090219170318.3f7d54f2@extreme> <499E04C9.4020308@hp.com> <499E7B03.9090409@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <499E7B03.9090409@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Fair enough. Is there a tree somewhere I can pull with all those in 
>> it, or do I need to go back through the emails and apply patches?
> 
> 
> You can use my nf-next.git tree from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git
> 
> It contains the lock free counters, as well as smaller optimizations
> from Eric. 

So, by the time this hits inboxes, under:

ftp://ftp.netperf.org/nf-next-2.6-results

should be a directory called "baseline" which are the results from just a clone 
of your tree from earlier today.  There you will find the config file, the log of 
the build and then three subdirectories:

none - results without doing iptables --list
empty - results after doing iptables --list
full - results after doing an iptables-restore of a config from the "iptables" 
file also up there

In each will be the netperf results in csv format, and four different caliper 
(using the perfmon interface) profiles:

"cycles" uses a profile which is able to take samples with interrupts disabled
"fprof" is a plain flat profile that does not see things happening with interrupt 
s disabled - comparing an fprof to cycles is sometimes interesting
"dcache" tries to take cache miss profiles. iirc that uses the data ear in the 
Itanium PMU to do its thing - I cannot recall the effect of interrupt disabling there
"scgprof" is a sampled call graph profile - likely as not with interrupt 
limitations similar to those of an fprof profile.

> The last timer patch I've seen missed the actual conversion
> to use mod_timer_pending(), but it would be great to have some numbers
> on the conntrack lock changes. Thanks Rick!

I will go back through my email now and try to find the conntrack lock changes 
and apply them to the tree and turn the crank.

happy benchmarking

rick jones
