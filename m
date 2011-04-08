From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Fri, 08 Apr 2011 09:22:01 -0700
Message-ID: <4D9F3629.9020506@intel.com>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>	 <1302152327.2701.50.camel@edumazet-laptop>	 <1302153412.2701.64.camel@edumazet-laptop>	 <1302157012.2701.73.camel@edumazet-laptop>	 <D12839161ADD3A4B8DA63D1A134D084026E48B9E82@ESGSCCMS0001.eapac.ericsson.se>	 <1302163650.3357.8.camel@edumazet-laptop>	 <D12839161ADD3A4B8DA63D1A134D084026E48B9F23@ESGSCCMS0001.eapac.ericsson.se>	 <1302167168.3357.12.camel@edumazet-laptop>	 <D12839161ADD3A4B8DA63D1A134D084026E48BA027@ESGSCCMS0001.eapac.ericsson.se>	 <1302176811.3357.15.camel@edumazet-laptop>  <4D9DDF43.9080302@intel.com>	 <1302192218.3357.47.camel@edumazet-laptop> <4D9DE465.1080008@intel.com>	 <D12839161ADD3A4B8DA63D1A134D084026E48BA58D@ESGSCCMS0001.eapac.ericsson.se> <1302253651.4409.2.camel@edumazet-lapt
 op> <D12839161ADD3A4B8DA63D1A134D084026E48BA66B@ESGSCCMS0001.eapac.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Wei Gu <wei.gu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:9386 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752636Ab1DHQWD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2011 12:22:03 -0400
In-Reply-To: <D12839161ADD3A4B8DA63D1A134D084026E48BA66B@ESGSCCMS0001.eapac.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/8/2011 5:19 AM, Wei Gu wrote:
> Hi again,
> I tried more testing with by disable this CONFIG_DMAR with shipped 2.6.38 ixgbe and Intel released 3.2.10/3.1.15.
> All these test looks we can get>1Mpps 400bype packtes but not stable at all, there will huge number missing errors with 100% CPU IDLE:
> ethtool -S eth10 |grep rx_missed_errors
>
>          rx_missed_errors: 76832040
>
> SUM: 1102212 ETH8: 0  ETH10: 1102212 ETH6: 0 ETH4: 0
> SUM: 521841 ETH8: 0  ETH10: 521841 ETH6: 0 ETH4: 0
> SUM: 426776 ETH8: 0  ETH10: 426776 ETH6: 0 ETH4: 0
> SUM: 927520 ETH8: 0  ETH10: 927520 ETH6: 0 ETH4: 0
> SUM: 1171995 ETH8: 0  ETH10: 1171995 ETH6: 0 ETH4: 0
> SUM: 855980 ETH8: 0  ETH10: 855980 ETH6: 0 ETH4: 0
>
>
> Do you know if there is other options in the kernel will cause high rate rx_missed_errors with low CPU usage. (No problem on 2.6.32 with same test case)
>
> perf  record:
> +     69.74%          swapper  [kernel.kallsyms]          [k] poll_idle
> +     11.62%          swapper  [kernel.kallsyms]          [k] intel_idle
> +      0.80%          swapper  [ixgbe]                    [k] ixgbe_poll
> +      0.79%             perf  [ixgbe]                    [k] ixgbe_poll
> +      0.77%             perf  [kernel.kallsyms]          [k] skb_copy_bits
> +      0.64%          swapper  [kernel.kallsyms]          [k] skb_copy_bits
> +      0.48%             perf  [kernel.kallsyms]          [k] __kmalloc_node_track_caller
> +      0.44%          swapper  [kernel.kallsyms]          [k] __kmalloc_node_track_caller
> +      0.36%          swapper  [kernel.kallsyms]          [k] kmem_cache_alloc_node
> +      0.35%          swapper  [kernel.kallsyms]          [k] kfree
> +      0.35%             perf  [kernel.kallsyms]          [k] kmem_cache_alloc_node

I was wondering if you could dump all of your ethtool stats instead of 
just the rx_missed_errors as this will provide us with much more info to 
work with.

I'm mainly interested in seeing if the rx_no_buffer_count is 
incrementing as well.  If it is not then what you may be seeing is a bus 
bandwidth issue depending on what slot you are in.

Also if you could provide an lspci dump for the part that would also 
give us some additional information on your PCIe bus configuration.

Thanks,

Alex
