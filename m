From: Otto Sabart <osabart@redhat.com>
Subject: Re: [BUG] net: performance regression on ixgbe (Intel 82599EB
 10-Gigabit NIC)
Date: Thu, 10 Dec 2015 15:18:29 +0100
Message-ID: <20151210141825.GA27930@redhat.com>
References: <20151203162627.GA8989@redhat.com>
 <5661D7D7.4020401@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jirka Hladky <jhladky@redhat.com>,
	Adam Okuliar <aokuliar@redhat.com>,
	Kamil Kolakowski <kkolakow@redhat.com>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43113 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752213AbbLJOSa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Dec 2015 09:18:30 -0500
Content-Disposition: inline
In-Reply-To: <5661D7D7.4020401@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rick,

> *)  It is good to be binding netperf and netserver - helps with
> reproducibility, but why the two -T options?  A brief look at src/netsh.c
> suggests it will indeed set the two binding options separately but that is
> merely a side-effect of how I wrote the code.  It wasn't an intentional
> thing.

It's because of the way we generate arguments for netperf.
'-T 0, -T ,0' does the same as '-T 0,0', but the first option is more
convenient for us.

> *) Is irqbalance disabled and the IRQs set the same each time, or might
> there be variability possible there?  Each of the five netperf runs will be
> a different four-tuple which means each may (or may not) get RSS hashed/etc
> differently.

The irqbalance is disabled on all systems.

Can you suggest, if there is a need to assign irqs manually? Which irqs
we should pin to which CPU?

> *) It is perhaps adding duct tape to already-present belt and suspenders,
> but is power-management set to a fixed state on the systems involved? (Since
> this seems to be ProLiant G7s going by the legends on the charts, either
> static high perf or static low power I would imagine)

Power management is set to OS-Control in bios, which effectively means,
that _bios_ does not do any power management at all.

> *) What is the difference before/after for the service demands?  The netperf
> tests being run are asking for CPU utilization but I don't see the service
> demand change being summarized.

Unfortunatelly we does not have any summary chart for service demands,
we will add some shortly.

> *) Does a specific CPU on one side or the other saturate?
> (LOCAL_CPU_PEAK_UTIL, LOCAL_CPU_PEAK_ID, REMOTE_CPU_PEAK_UTIL,
> REMOTE_CPU_PEAK_ID output selectors)

We are sort of stuck in a stone age. We still use old fashion tcp/udp
migrated tests, but we plan to switch to omni.

> *) What are the processors involved?  Presumably the "other system" is
> fixed?

In this case:

hp-dl380g7 - $ lscpu:
Architecture:          x86_64
CPU op-mode(s):        32-bit, 64-bit
Byte Order:            Little Endian
CPU(s):                24
On-line CPU(s) list:   0-23
Thread(s) per core:    2
Core(s) per socket:    6
Socket(s):             2
NUMA node(s):          2
Vendor ID:             GenuineIntel
CPU family:            6
Model:                 44
Model name:            Intel(R) Xeon(R) CPU           X5650  @ 2.67GHz
Stepping:              2
CPU MHz:               2660.000
BogoMIPS:              5331.27
Virtualization:        VT-x
L1d cache:             32K
L1i cache:             32K
L2 cache:              256K
L3 cache:              12288K
NUMA node0 CPU(s):     0,2,4,6,8,10,12,14,16,18,20,22
NUMA node1 CPU(s):     1,3,5,7,9,11,13,15,17,19,21,23


hp-dl385g7 - $ lscpu:
tecture:          x86_64
CPU op-mode(s):        32-bit, 64-bit
Byte Order:            Little Endian
CPU(s):                24
On-line CPU(s) list:   0-23
Thread(s) per core:    1
Core(s) per socket:    12
Socket(s):             2
NUMA node(s):          4
Vendor ID:             AuthenticAMD
CPU family:            16
Model:                 9
Model name:            AMD Opteron(tm) Processor 6172
Stepping:              1
CPU MHz:               2100.000
BogoMIPS:              4200.39
Virtualization:        AMD-V
L1d cache:             64K
L1i cache:             64K
L2 cache:              512K
L3 cache:              5118K
NUMA node0 CPU(s):     0,2,4,6,8,10
NUMA node1 CPU(s):     12,14,16,18,20,22
NUMA node2 CPU(s):     13,15,17,19,21,23
NUMA node3 CPU(s):     1,3,5,7,9,11


Thank you for your hints!

Ota
