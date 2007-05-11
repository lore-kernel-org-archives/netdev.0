From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: Kconfig warnings on latest GIT
Date: Thu, 10 May 2007 20:41:53 -0500
Message-ID: <996E281D-DE15-451A-955D-FB9C0C23DA54@kernel.crashing.org>
References: <200705080004.14570.ismail@pardus.org.tr> <20070508143127.38fafa3c.kim.phillips@freescale.com> <4640D988.1040504@freescale.com> <20070510051042.GA16812@verge.net.au> <46434ED0.6030808@freescale.com> <20070511012529.GC10715@verge.net.au>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Timur Tabi <timur@freescale.com>,
	Kim Phillips <kim.phillips@freescale.com>,
	Linux Kernel list <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Roman Zippel <zippel@linux-m68k.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Sam Ravnborg <sam@ravnborg.org>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nommos.sslcatacombnetworking.com ([67.18.224.114]:18682 "EHLO
	nommos.sslcatacombnetworking.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751580AbXEKBzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 21:55:43 -0400
In-Reply-To: <20070511012529.GC10715@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On May 10, 2007, at 8:25 PM, Simon Horman wrote:

> On Thu, May 10, 2007 at 11:56:48AM -0500, Timur Tabi wrote:
>> Simon Horman wrote:
>>
>>>> So my question is: in which Kconfig do I define "UCC_FAST_TEMP" and
>>>> "UCC_SLOW_TEMP"?  At first I thought, just put it in drivers/ 
>>>> Kconfig, but
>>>> that Kconfig does nothing but including other Kconfigs.  I  
>>>> believe that if I
>>>> submit a patch that adds "UCC_FAST_TEMP" and "UCC_SLOW_TEMP" to
>>>> drivers/Kconfig, it will be rejected.  Either that, or I'll  
>>>> spend six weeks
>>>> trying to persuade everyone that it's a good idea.
>>>>
>>>> Does anyone have any suggestions on how I can fix this?
>>> That does seem like a reasonable suggestion, and one that
>>> would probably work well with the other similar problems
>>> that have been introduced sice 2.6.21.
>>
>> Looks like the fix is simpler than I thought.  Instead of having
>>
>> UCC_GETH
>> 	select UCC_FAST
>>
>> I need to do
>>
>> UCC_FAST
>> 	default y if UCC_GETH
>
> I pondered something like that, but I couldn't get it quite right :(
>
>> I'll have a patch that fixes this out later today.
>>
>> I chose the first method because I wanted each individual UCC device
>> driver to select UCC_FAST or UCC_SLOW as appropriate, so that I
>> wouldn't have to update arch/powerpc/sysdev/qe_lib/Kconfig every time
>> we add a new UCC driver.  Oh well.

It really seems like the kconfig shouldn't complain if the depends  
isnt satisfied.

- k
