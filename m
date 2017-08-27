From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH] pktgen: add a new sample script for 40G and above link
 testing
Date: Sun, 27 Aug 2017 11:25:03 +0300
Message-ID: <800696cf-477e-52bf-24ae-a0a6c19a5f2d@mellanox.com>
References: <1503653196-64418-1-git-send-email-robert.hu@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, robert.hu@intel.com
To: Robert Hoo <robert.hu@linux.intel.com>, davem@davemloft.net,
        tariqt@mellanox.com, brouer@redhat.com, kyle.leet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr50051.outbound.protection.outlook.com ([40.107.5.51]:33184
        "EHLO EUR03-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750797AbdH0IZN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Aug 2017 04:25:13 -0400
In-Reply-To: <1503653196-64418-1-git-send-email-robert.hu@linux.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 25/08/2017 12:26 PM, Robert Hoo wrote:
> (Sorry for yesterday's wrong sending, I finally fixed my MTA and git
> send-email settings.)
> 
> It's hard to benchmark 40G+ network bandwidth using ordinary
> tools like iperf, netperf (see reference 1).
> Pktgen, packet generator from Kernel sapce, shall be a candidate.
> I then tried with pktgen multiqueue sample scripts, but still
> cannot reach line rate.

Try samples 03 and 04.

> I then derived this NUMA awared irq affinity sample script from
> multi-queue sample one, successfully benchmarked 40G link. I think this can
> also be useful for 100G reference, though I haven't got device to test yet.
> 
> This script simply does:
> Detect $DEV's NUMA node belonging.
> Bind each thread (processor from that NUMA node) with each $DEV queue's
> irq affinity, 1:1 mapping.
> How many '-t' threads input determines how many queues will be
> utilized.

I agree this is an essential capability.
This was the main reason I added support for the -f argument.
Using it, I could choose cores of local NUMA, especially for single 
thread, or when cores of the NUMA are sequential.

> 
> Tested with Intel XL710 NIC with Cisco 3172 switch.
> 
> It would be even slightly better if the irqbalance service is turned
> off outside.
> 
> Referrences:
> https://people.netfilter.org/hawk/presentations/LCA2015/net_stack_challenges_100G_LCA2015.pdf
> http://www.intel.cn/content/dam/www/public/us/en/documents/reference-guides/xl710-x710-performance-tuning-linux-guide.pdf
> 
> Signed-off-by: Robert Hoo <robert.hu@linux.intel.com>
> ---

Regards,
Tariq Toukan
