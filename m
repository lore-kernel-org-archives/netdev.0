From: David Miller <davem@davemloft.net>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Wed, 04 Dec 2013 01:39:33 -0500 (EST)
Message-ID: <20131204.013933.873780415547689253.davem@davemloft.net>
References: <1386107714.30495.40.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAJZOPZ+bkvg4G6qzY6YmMui9-KmGmpHyFCJUD2xsFLOXm12rgA@mail.gmail.com>
	<1386115199.30495.44.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: or.gerlitz@gmail.com, joseph.gasparakis@intel.com,
	hkchu@google.com, ogerlitz@mellanox.com, edumazet@google.com,
	ast@plumgrid.com, pshelar@nicira.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40646 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238Ab3LDGjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 01:39:35 -0500
In-Reply-To: <1386115199.30495.44.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 03 Dec 2013 15:59:59 -0800

> On Wed, 2013-12-04 at 01:10 +0200, Or Gerlitz wrote:
> 
>> Samples: 883K of event 'skb:kfree_skb', Event count (approx.): 883406
>> +  97.13%          swapper  [kernel.kallsyms]  [k] net_tx_action
>> +   1.53%            iperf  [kernel.kallsyms]  [k] net_tx_action
>> +   1.03%             perf  [kernel.kallsyms]  [k] net_tx_action
>> +   0.27%      ksoftirqd/7  [kernel.kallsyms]  [k] net_tx_action
>> +   0.03%      kworker/7:1  [kernel.kallsyms]  [k] net_tx_action
>> +   0.00%          rpcbind  [kernel.kallsyms]  [k] net_tx_action
>> +   0.00%          swapper  [kernel.kallsyms]  [k] kfree_skb
>> +   0.00%            sleep  [kernel.kallsyms]  [k] net_tx_action
>> +   0.00%  hald-addon-acpi  [kernel.kallsyms]  [k] kfree_skb
>> +   0.00%            iperf  [kernel.kallsyms]  [k] kfree_skb
>> +   0.00%             perf  [kernel.kallsyms]  [k] kfree_skb
>> 
> 
> Right, I actually have a patch for that, but was waiting for net-next
> being re-opened :
> 
> commit 9a731d750dd8bf0b8c20fb1ca53c42317fb4dd37
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Mon Nov 25 13:09:20 2013 -0800
> 
>     net-fixes: introduce dev_consume_skb_any()

I definitely prefer the control block approach to this.
