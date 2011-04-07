From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Thu, 07 Apr 2011 08:58:59 -0700
Message-ID: <4D9DDF43.9080302@intel.com>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>	 <1302152327.2701.50.camel@edumazet-laptop>	 <1302153412.2701.64.camel@edumazet-laptop>	 <1302157012.2701.73.camel@edumazet-laptop>	 <D12839161ADD3A4B8DA63D1A134D084026E48B9E82@ESGSCCMS0001.eapac.ericsson.se>	 <1302163650.3357.8.camel@edumazet-laptop>	 <D12839161ADD3A4B8DA63D1A134D084026E48B9F23@ESGSCCMS0001.eapac.ericsson.se>	 <1302167168.3357.12.camel@edumazet-laptop>	 <D12839161ADD3A4B8DA63D1A134D084026E48BA027@ESGSCCMS0001.eapac.ericsson.se> <1302176811.3357.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wei Gu <wei.gu@ericsson.com>, netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:3096 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753694Ab1DGP67 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2011 11:58:59 -0400
In-Reply-To: <1302176811.3357.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/7/2011 4:46 AM, Eric Dumazet wrote:
> Le jeudi 07 avril 2011 =C3=A0 19:15 +0800, Wei Gu a =C3=A9crit :
>> Hi,
>> I compile the ixgbe driver into the kernel and run the test again an=
d also change the copy to clone in the fw hook
>> This is the perf report while I was forwarding 150Kpps with
>> The attached file include the basic info about my test system. Pleas=
e let me know if I did some thing wrong.
>>
>> +     71.91%          swapper  [kernel.kallsyms]            [k] poll=
_idle
>> +     10.43%          swapper  [kernel.kallsyms]            [k] inte=
l_idle
>> -      8.00%     ksoftirqd/24  [kernel.kallsyms]            [k] _raw=
_spin_unlock_irqrestore
>> \u2592   - _raw_spin_unlock_irqrestore
>> \u2592      - 42.25% alloc_iova
>> \u2592           intel_alloc_iova
>> \u2592           __intel_map_single
>> \u2592           intel_map_page

I'm almost certain this is the issue here.  I am pretty sure the=20
intel_map_page call indicates that you are running with the Intel IOMMU=
=20
enabled.  As Eric suggested you can either rebuild your kernel with=20
"CONFIG_DMAR=3DN", or pass the kernel the parameter "intel_iommu=3Doff"=
 in=20
order to disable it so that it will instead just use SWIOTLB.

Thanks,

Alex

