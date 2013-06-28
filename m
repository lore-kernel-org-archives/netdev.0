From: Cody P Schafer <devel-lists@codyps.com>
Subject: Re: [PATCH v4 net-next] net: poll/select low latency socket support
Date: Thu, 27 Jun 2013 17:29:58 -0700
Message-ID: <51CCD906.6030902@codyps.com>
References: <20130624072751.26134.78163.stgit@ladj378.jer.intel.com> <20130624072803.26134.41593.stgit@ladj378.jer.intel.com> <51CCD812.5090408@codyps.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <erdnetdev@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Alex Rosenbaum <alexr@mellanox.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51CCD812.5090408@codyps.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/27/2013 05:25 PM, Cody P Schafer wrote:
> On 06/24/2013 12:28 AM, Eliezer Tamir wrote:
>> select/poll busy-poll support.
>> ...
>
> I'm seeing warnings about using smp_processor_id() while preemptable
> (log included below) due to this patch. I expect the use of
> ll_end_time() -> sched_clock() here is triggering this.
>
> Apologies if this has already been noted.

To be clear, given how sched_time() is used here the BUG appears 
invalid, but we need a way to mark this as OK for the smp_processor_id() 
checks so we don't get BUG spam.

> --
>
> # [    3.114452] BUG: using smp_processor_id() in preemptible [00000000]
> code: sh/62
...
