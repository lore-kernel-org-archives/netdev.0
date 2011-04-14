From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Thu, 14 Apr 2011 09:42:25 -0700
Message-ID: <4DA723F1.7000901@intel.com>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>	 <1302253651.4409.2.camel@edumazet-laptop>	 <D12839161ADD3A4B8DA63D1A134D084026E48BA66B@ESGSCCMS0001.eapac.ericsson.se>	 <1302267400.4409.22.camel@edumazet-laptop>	 <D12839161ADD3A4B8DA63D1A134D084026E48BA682@ESGSCCMS0001.eapac.ericsson.se>	 <1302275223.4409.36.camel@edumazet-laptop>	 <D12839161ADD3A4B8DA63D1A134D084026E48BA6AE@ESGSCCMS0001.eapac.ericsson.se>	 <1302330998.2656.113.camel@edumazet-laptop>	 <D12839161ADD3A4B8DA63D1A134D084026E48BA730@ESGSCCMS0001.eapac.ericsson.se>	 <4DA3151B.4030507@intel.com>	 <D12839161ADD3A4B8DA63D1A134D084026E4909714@ESGSCCMS0001.eapac.ericsson.se>	 <1302536577.4605.1.camel@edumazet-laptop>	 <D12839161ADD3A4B8DA63D1A134D084026E49535F2@ESGSCCMS0001.eapac.ericsson.se>	 
 <1302761251.3549.198.camel@edumazet-laptop> <1302762810.3549.233.camel@edumazet-laptop> <D12839161ADD3A4B8DA63D1A134D084026E49536AF@ESGSCCMS0001.eapac.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Wei Gu <wei.gu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:31569 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750968Ab1DNQnM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Apr 2011 12:43:12 -0400
In-Reply-To: <D12839161ADD3A4B8DA63D1A134D084026E49536AF@ESGSCCMS0001.eapac.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/13/2011 11:58 PM, Wei Gu wrote:
> I did the single flow test, it shows no rx error with 300kpps. While =
I was start multiple flow with same 300Kpps traffic, then it looks real=
ly bad with high rx_missing_error.
>
> Multiple Flow:
> SUM: 191925 ETH8: 0  ETH10: 191925 ETH6: 0 ETH4: 0
> SUM: 214634 ETH8: 0  ETH10: 214634 ETH6: 0 ETH4: 0
> SUM: 237600 ETH8: 0  ETH10: 237600 ETH6: 0 ETH4: 0
> SUM: 198925 ETH8: 0  ETH10: 198925 ETH6: 0 ETH4: 0
> SUM: 249290 ETH8: 0  ETH10: 249290 ETH6: 0 ETH4: 0
>
> Single Flow:
> SUM: 302018 ETH8: 0  ETH10: 302018 ETH6: 0 ETH4: 0
> SUM: 301849 ETH8: 0  ETH10: 301849 ETH6: 0 ETH4: 0
> SUM: 302163 ETH8: 0  ETH10: 302163 ETH6: 0 ETH4: 0
>
> Thanks
> WeiGu
> -----Original Message-----
> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> Sent: Thursday, April 14, 2011 2:34 PM
> To: Wei Gu
> Cc: Alexander Duyck; Peter Zijlstra; netdev; Kirsher, Jeffrey T
> Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
>
> Le jeudi 14 avril 2011 =E0 08:07 +0200, Eric Dumazet a =E9crit :
>> Le jeudi 14 avril 2011 =E0 13:42 +0800, Wei Gu a =E9crit :
>>> Hi guys,
>>> Do you think it was a bug in the kernel from 2.6.35.2 with Intel 10=
GE ixgbe driver?
>>> If so shall I issue a Bug on the bugzilla, and which category? Caus=
e I'm not sure it was driver problem Or sched problem.
>>
>> This makes no sense to me.
>>
>> What is the maximum throughput you can get in pps before having pack=
et
>> drops ?
>>
>> Please try with a single flow (to hit one queue, one cpu)
>>
>> Thanks
>>
>
> Also, please try to check if using smaller or bigger packets makes an=
y change in this max throughput
>
>

The only issue I have found so far with the ixgbe driver is the fact=20
that apparently rx_no_buffer_count is apparently always going to be 0 o=
n=20
82599, and that isn't so much a driver problem as a hardware limitation=
=20
as the HW counter was removed in 82599.  However since the hardware was=
=20
capable of going faster on the other kernels what this likely means is=20
that the rx_missed_errors are due to the driver not providing Rx buffer=
s=20
fast enough.

I'm doing some more digging into this now.  One thought that occurred t=
o=20
me is that if the patch you mention is having some sort of effect this=20
could be a sign of perhaps a kernel timer or scheduling problem.

Thanks,

Alex
