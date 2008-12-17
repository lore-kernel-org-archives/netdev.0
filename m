From: Divy Le Ray <divy@chelsio.com>
Subject: Re: Soft Lockups on 2.6.28-rc8 under netperf bulk receive workload
Date: Wed, 17 Dec 2008 09:20:05 -0800
Message-ID: <494934C5.5000003@chelsio.com>
References: <4948566E.1050309@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	linux-ia64@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <linux-ia64-owner@vger.kernel.org>
In-Reply-To: <4948566E.1050309@hp.com>
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> I have a 32-core, 1.6 GHz Montvale hp rx8640 with 128 GB of RAM (64x2GB 
> DIMMS) configured as ILM (interleave memory on a cacheline boundary) 
> rather than cell local memory.  HyperThreading is disabled.  The system 
> has four AD386A PCIe 10G Ethernet interfaces each in a separate PCIe x8 
> slot.  The AD386A is a single-port card based on the Chelsio T3C chip. 
> The interrupts of the 8 queues on each card are spread across the 32 
> cores - 8 queues of card one to cores 0-7 one to one, those of card two 
> to cores 8-15, etc etc.  The NICs are in turn connected to an HP 
> ProCurve 5406 with a number of 10G modules, which then connect to four, 
> 4P/16C, 2.3 GHz Opteron 8356 HP DL585 G5's each with two AD386As also in 
> x8 slots or better.  I configure four subnets - 192.168.[2345]/24, set 
> arp_ignore to one (since they are all carried on the same switch) and 
> all five systems are in all four subnets (two IP's per interface on the 
> DL585s.
> 
> The MTU on all interfaces is 1500 bytes.  cxgb3 driver settings are 
> default. net.core.[rw]mem_max is set to 4194304 and netperf is making 
> explicit setsockopt calls asking for 1MB SO_[SND|RCV]BUF values.
> 
> I then launch 64 concurrent netperf TCP_MAERTS tests (actually the 
> "omni" test equivalent which does the same thing) from the rx8640.  This 
> causes each of the DL585 G5's to start sending data to the rx8640.
> 
> I was first running a not-yet-released distro based on an old 2.6 kernel 
> and the 1.1.022 out-of-tree cxgb3 driver and saw soft lockups.  I then 
> moved on to a Debian Lenny 2.6.26 kernel, still with the same 
> out-of-tree driver and saw soft lockups.
> 
> Presently, the system is running a 2.6.28-rc8 kernel from kernel.org 
> with the in-tree cxgb3 driver and I still see soft lockups which look like:


Hi Rick,

Can you please reconfigure your kernel with the following kernel hacking
options enabled, and run your tests again?

Kernel hacking
	Kernel debugging
		Detect soft lockups
	RT mutex debugging
	Spinlock and rw-lock debugging: basic checks
	Mutex debugging: basic checks
	Lock debugging: detect incorrect freeing of live locks
	Lock debugging: prove locking correctness
	Spinlock debugging: sleep-inside-spinlock checking
	Compile the kernel with debug info
	Compile the kernel with frame pointers

Cheers,
Divy
