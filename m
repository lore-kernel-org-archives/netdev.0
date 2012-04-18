From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: avoid expensive pskb_expand_head() calls
Date: Wed, 18 Apr 2012 19:40:48 +0200
Message-ID: <1334770848.2472.314.camel@edumazet-glaptop>
References: <1334653608.6226.11.camel@edumazet-laptop>
	 <1334654187.2696.2.camel@jtkirshe-mobl>  <4F8D93E1.9090000@intel.com>
	 <1334681204.2472.41.camel@edumazet-glaptop>
	 <1334698722.2472.71.camel@edumazet-glaptop>
	 <1334764184.2472.299.camel@edumazet-glaptop>  <4F8EF317.10504@hp.com>
	 <1334769375.2472.310.camel@edumazet-glaptop>  <4F8EFA24.8020909@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:48602 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751456Ab2DRRkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 13:40:55 -0400
Received: by bkcik5 with SMTP id ik5so5705818bkc.19
        for <netdev@vger.kernel.org>; Wed, 18 Apr 2012 10:40:54 -0700 (PDT)
In-Reply-To: <4F8EFA24.8020909@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-04-18 at 10:30 -0700, Rick Jones wrote:

> I was thinking more about the race if any between the ACK for the last 
> byte of the 64 KB skb and the transmit completion processing freeing it 
> in the driver.  But that may be moot.
> 

No race, its done with atomic operations.


> >
> > # perf stat -r 5 -d -d -o RES.before taskset 1 netperf -H 192.168.99.1 -l 20
> 
> I'm still learning about perf, and the manpage I have for it does not 
> discuss the -d option but is that doing system wide, or only in the 
> context of the netperf process?

In fact I used -a option and forgot to copy it in the mail I sent

perf stat -h

 usage: perf stat [<options>] [<command>]

    -e, --event <event>   event selector. use 'perf list' to list available events
        --filter <filter>
                          event filter
    -i, --no-inherit      child tasks do not inherit counters
    -p, --pid <pid>       stat events on existing process id
    -t, --tid <tid>       stat events on existing thread id
    -a, --all-cpus        system-wide collection from all CPUs
    -g, --group           put the counters into a counter group
    -c, --scale           scale/normalize counters
    -v, --verbose         be more verbose (show counter open errors, etc)
    -r, --repeat <n>      repeat command and print average + stddev (max: 100)
    -n, --null            null run - dont start any counters
    -d, --detailed        detailed run - start a lot of events
    -S, --sync            call sync() before starting a run
    -B, --big-num         print large numbers with thousands' separators
    -C, --cpu <cpu>       list of cpus to monitor in system-wide
    -A, --no-aggr         disable CPU count aggregation
    -x, --field-separator <separator>
                          print counts with custom separator
    -G, --cgroup <name>   monitor event in cgroup name only
    -o, --output <file>   output file name
        --append          append to the output file
        --log-fd <n>      log output to fd, instead of stderr
