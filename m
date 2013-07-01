From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net: lls cleanup patches
Date: Mon, 01 Jul 2013 14:08:33 -0700 (PDT)
Message-ID: <20130701.140833.1705666564717621661.davem@davemloft.net>
References: <20130628125918.14419.36214.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	willemb@google.com, erdnetdev@gmail.com, andi@firstfloor.org,
	hpa@zytor.com, devel-lists@codyps.com, eliezer@tamir.org.il
To: eliezer.tamir@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130628125918.14419.36214.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Date: Fri, 28 Jun 2013 15:59:18 +0300

> Here are two cleanup patches.
> 
> 1. fix warning from debug_smp_processor_id().
> - reported by Cody P Schafer.
> 
> 2. avoid calling sched_clock() in select and poll when lls is disabled.
> - reported by Andi Kleen.
> 
> Thanks to everyone for their comments.

Applied, but like Ben said perhaps you want to remember the last cpu you
got the sched_clock() measurement from and abort the ll poll if it changes
on you instead of using a comparison between two cpus.

But then again, since preemption is enabled, the cpu could change
back and forth during the sched_clock() call, so you wouldn't be able
to reliably detect this anyways.

In the grand scheme of things all of this probably doesn't matter at
all.
