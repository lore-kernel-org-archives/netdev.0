From: Robert Hoo <robert.hu@linux.intel.com>
Subject: Re: [PATCH] pktgen: add a new sample script for 40G and above link
 testing
Date: Fri, 01 Sep 2017 21:53:48 +0800
Message-ID: <1504274028.50064.25.camel@linux.intel.com>
References: <1503653196-64418-1-git-send-email-robert.hu@linux.intel.com>
         <800696cf-477e-52bf-24ae-a0a6c19a5f2d@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, brouer@redhat.com, kyle.leet@gmail.com,
        netdev@vger.kernel.org
To: Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:58577 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751966AbdIANxu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 09:53:50 -0400
In-Reply-To: <800696cf-477e-52bf-24ae-a0a6c19a5f2d@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-08-27 at 11:25 +0300, Tariq Toukan wrote:
> 
> On 25/08/2017 12:26 PM, Robert Hoo wrote:
> > (Sorry for yesterday's wrong sending, I finally fixed my MTA and git
> > send-email settings.)
> > 
> > It's hard to benchmark 40G+ network bandwidth using ordinary
> > tools like iperf, netperf (see reference 1).
> > Pktgen, packet generator from Kernel sapce, shall be a candidate.
> > I then tried with pktgen multiqueue sample scripts, but still
> > cannot reach line rate.
> 
> Try samples 03 and 04.

Thanks Tariq for review. Sorry for late reply; I do this part time.

Yes, I just tried sample 03 and 04. They can approximately reach 40G
line rate; though still slightly less than my script :) (see my reply
to Jesper).
> 
> > I then derived this NUMA awared irq affinity sample script from
> > multi-queue sample one, successfully benchmarked 40G link. I think this can
> > also be useful for 100G reference, though I haven't got device to test yet.
> > 
> > This script simply does:
> > Detect $DEV's NUMA node belonging.
> > Bind each thread (processor from that NUMA node) with each $DEV queue's
> > irq affinity, 1:1 mapping.
> > How many '-t' threads input determines how many queues will be
> > utilized.
> 
> I agree this is an essential capability.
> This was the main reason I added support for the -f argument.
> Using it, I could choose cores of local NUMA, especially for single 
> thread, or when cores of the NUMA are sequential.

Indeed this argument is very helpful.
Sorry I haven't taken it into consideration in v1. I should consider
this, what if user designate '-f'. I can improve this in v2.
> 
> > 
> > Tested with Intel XL710 NIC with Cisco 3172 switch.
> > 
> > It would be even slightly better if the irqbalance service is turned
> > off outside.
> > 
> > Referrences:
> > https://people.netfilter.org/hawk/presentations/LCA2015/net_stack_challenges_100G_LCA2015.pdf
> > http://www.intel.cn/content/dam/www/public/us/en/documents/reference-guides/xl710-x710-performance-tuning-linux-guide.pdf
> > 
> > Signed-off-by: Robert Hoo <robert.hu@linux.intel.com>
> > ---
> 
> Regards,
> Tariq Toukan
