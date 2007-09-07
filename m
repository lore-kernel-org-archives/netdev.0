From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: 2.6.23-rc4-mm1: e1000e napi lockup
Date: Fri, 07 Sep 2007 16:52:54 -0700
Message-ID: <46E1E456.8020605@intel.com>
References: <46E0FB82.2040000@gmail.com> <20070907.010338.41638771.davem@davemloft.net> <46E17B41.4060200@intel.com> <46E1DF6E.6050801@garzik.org> <46E1E15E.7080406@intel.com> <46E1E391.7090907@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jirislaby@gmail.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:12437 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751303AbXIGXw5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2007 19:52:57 -0400
In-Reply-To: <46E1E391.7090907@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Kok, Auke wrote:
>> Jeff Garzik wrote:
>>> Kok, Auke wrote:
>>>> David Miller wrote:
>>>>> From: Jiri Slaby <jirislaby@gmail.com>
>>>>> Date: Fri, 07 Sep 2007 09:19:30 +0200
>>>>>
>>>>>> I found a regression in 2.6.23-rc4-mm1 (since -rc3-mm1) in e1000e 
>>>>>> driver.
>>>>>> napi_disable(&adapter->napi) in e1000_probe freezes the kernel on 
>>>>>> boot.
>>>>> Yes, the semantics changed slightly in the net-2.6.24 tree the
>>>>> other week and someone needs to fix it up.
>>>>>
>>>>> The netif_napi_add() implicitly does a napi_disable() call.  Device
>>>>> open must explicitly napi_enable() and device close must explicitly
>>>>> napi_disable(), and if done elsewhere these calls must be strictly
>>>>> balanced.
>>>> I'll fix it... it's my patch that adds the new napi code to it and I 
>>>> need to get it ready for the merge window anyway.
>>> well....  since its close to the merge window opening, we could see 
>>> what happens if DaveM pulls branch 'upstream' of 
>>> git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git
>>>
>>> That should make this class of pre-merge-window annoyance go away.
>> If I do that now I get a big merge conflict:
> 
> oh you are _guaranteed_ conflicts.  most of that is NAPI-area code that 
> got changed by both.


actually that's the only thing it was, and fixing it up was trivial (took me 
about 3 minutes). it was 3x the napi code and once a struct indent change...

I'll have a new e1000e napi patch for andrew in a sec.

Auke
