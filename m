From: Alexander H Duyck <alexander.h.duyck@intel.com>
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Fri, 08 Apr 2011 21:40:57 -0700
Message-ID: <1302324057.15899.20.camel@ahduyck-mobl2.amr.corp.intel.com>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>
	 <1302152327.2701.50.camel@edumazet-laptop>
	 <1302153412.2701.64.camel@edumazet-laptop>
	 <1302157012.2701.73.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48B9E82@ESGSCCMS0001.eapac.ericsson.se>
	 <1302163650.3357.8.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48B9F23@ESGSCCMS0001.eapac.ericsson.se>
	 <1302167168.3357.12.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA027@ESGSCCMS0001.eapac.ericsson.se>
	 <1302176811.3357.15.camel@edumazet-laptop>  <4D9DDF43.9080302@intel.com>
	 <1302192218.3357.47.camel@edumazet-laptop> <4D9DE465.1080008@intel.com>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA58D@ESGSCCMS0001.eapac.ericsson.se>
	 <1302253651.4409.2.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA66B@ESGSCCMS0001.eapac.ericsson.se>
	 <4D9F3629.9020506@intel.com>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA6AF@ESGSCCMS0001.eapac.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Wei Gu <wei.gu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:7029 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751196Ab1DIEhf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Apr 2011 00:37:35 -0400
In-Reply-To: <D12839161ADD3A4B8DA63D1A134D084026E48BA6AF@ESGSCCMS0001.eapac.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-04-08 at 20:36 -0700, Wei Gu wrote:
> Hi Alexander, I do agree with you that if only the rx_missing_error
> (rx_no_buffer_count: 0) indicates the memory bandwidth issue. But the
> strange thing is I using the same test configuration on Linux 2.6.32,
> which looks no this problem at all. SO it not a HW setup problem at
> all, only difference in on the Kernel version, that's why I go back to
> you guys for this new Linux 2.6.38, if it will affact this memory
> bandwidth Or BIOS etc things?

What were the numbers you were getting with 2.6.32?  I would be
interested in seeing those number just to get an idea of how they
compare against the 2.6.38 kernel.

> The follow dump is done, while I was try to receive 290Kpps 400Byte
> pakets from IXIA, and drop them in the prerouting hook. I bind the
> eth10 8 RX queue to CPU sock ID 3 ( core 24-31) on NUMA NODE3

Just to confirm this is with DMAR off?  I saw an earlier email that said
you were getting a variable amount that was over 1Mpps and just want to
confirm this is with the same config.

> ethtool -i eth10
> driver: ixgbe
> version: 3.2.10-NAPI
> firmware-version: 0.9-3
> bus-info: 0000:8d:00.0
> 
> ethtool -S eth10
> NIC statistics:
>      rx_packets: 14222510
>      tx_packets: 109
>      rx_bytes: 5575223920
>      tx_bytes: 17790
>      rx_missed_errors: 15150244
>      rx_no_buffer_count: 0

I trimmed down your stats here pretty significantly.  This isn't an
issue with the driver not keeping up.  The problem here is memory and/or
bus bandwidth.  Based on the info you provided I am assuming you have a
quad socket system.  I'm curious how the memory is laid out.  What is
the total memory size, memory per node, and do you have all of the
memory channels on each node populated?  One common thing I've seen
cause these type of issues is an incorrect memory configuration.

Also if you could send me an lspci -vvv for 8d:00.0 specifically I would
appreciate it as I would like to look over the PCIe config just to make
sure the slot is a x8 PCIe gen 2.

Thanks,

Alex

