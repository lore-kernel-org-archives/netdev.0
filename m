From: Matheos Worku <Matheos.Worku@Sun.COM>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Thu, 27 Mar 2008 17:19:42 -0700
Message-ID: <47EC399E.90804@sun.com>
References: <20080327103340.GB2845@ami.dom.local>
 <36D9DB17C6DE9E40B059440DB8D95F5204C275C2@orsmsx418.amr.corp.intel.com>
 <47EC3182.7080005@sun.com> <20080327.170235.53674739.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: jesse.brandeburg@intel.com, jarkao2@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:54678 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752987AbYC1AU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 20:20:58 -0400
Received: from fe-sfbay-10.sun.com ([192.18.43.129])
	by sca-es-mail-2.sun.com (8.13.7+Sun/8.12.9) with ESMTP id m2S0KvMO006283
	for <netdev@vger.kernel.org>; Thu, 27 Mar 2008 17:20:58 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-10.sun.com by fe-sfbay-10.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0JYE00801ZG1BA00@fe-sfbay-10.sun.com>
 (original mail from Matheos.Worku@Sun.COM) for netdev@vger.kernel.org; Thu,
 27 Mar 2008 17:20:57 -0700 (PDT)
In-reply-to: <20080327.170235.53674739.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Matheos Worku <Matheos.Worku@Sun.COM>
> Date: Thu, 27 Mar 2008 16:45:06 -0700
>
>   
>> Brandeburg, Jesse wrote:
>>     
>>> Jarek Poplawski wrote:
>>>   
>>>       
>>>> On Wed, Mar 26, 2008 at 01:26:00PM -0700, Matheos Worku wrote:
>>>> ...
>>>>     
>>>>         
>>>>> nsn57-110 login: BUG: soft lockup - CPU#2 stuck for 11s! ... Call
>>>>> Trace: [<ffffffff803ef5f6>] __skb_clone+0x24/0xdc
>>>>> [<ffffffff803f152e>] skb_realloc_headroom+0x30/0x63
>>>>> [<ffffffff882edd40>] :niu:niu_start_xmit+0x114/0x5af
>>>>> [<ffffffff80221995>] gart_map_single+0x0/0x70
>>>>> [<ffffffff803f5e2b>] dev_hard_start_xmit+0x1d2/0x246 ...
>>>>>       
>>>>>           
>>>> Maybe I'm wrong with this again, but I wonder about this
>>>> gart_map_single on almost all traces, and probably not supposed to be
>>>> seen here. Did you try with some memory re-config/debugging?
>>>>     
>>>>         
>>> I have some more examples of this but with the ixgbe driver.  We are
>>> running heavy bidirectional stress with multiple rx (non-napi, yeah I
>>> know) interrupts by default (and userspace irqbalance is probably on,
>>> I'll have the lab try it without)
>>>   
>>>       
>> I have seen the lockup on kernels 2.6.18 and newer mostly on TX traffic. 
>> I have seen it on another 10G driver (off the tree niu driver sibling, 
>> nxge).  The nxge driver doesn't use any TX interrupts and I have seen it 
>> with UDP TX, irqbalance disabled, with no irq activity at all.  some 
>> example traces included.
>>     
>
> Interesting.
>
> Are you running uperf in a way such that there are multiple
> processors doing TX's in parallel?  That might be a clue.
>   
Dave,
Actually I am running a version of the nxge driver which uses only one 
TX ring, no LLTX enabled so the driver does single threaded TX. On the 
other hand, uperf (or iperf, netperf ) is running multiple TX 
connections in parallel and the connections are bound on multiple 
processors, hence they are running in parallel.

Regards
Matheos

