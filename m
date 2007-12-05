From: Chris Snook <csnook@redhat.com>
Subject: Re: [RFC] introducing the Atheros L2 Fast Ethernet driver
Date: Tue, 04 Dec 2007 21:06:33 -0500
Message-ID: <475607A9.90000@redhat.com>
References: <4755D39D.30005@redhat.com> <4755D8EA.9060201@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, synrg@debian.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42847 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751116AbXLECKc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 21:10:32 -0500
In-Reply-To: <4755D8EA.9060201@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> Chris Snook wrote:
>> Hey folks --
>>
>>     I've begun cleaning up the atl2 vendor driver for merging.  It's 
>> very similar to the atl1 driver, and needs a lot of the same work, 
>> though I have already fixed the 64-bit DMA data corrupter that atl1 
>> users remember so fondly.  Right now this is very raw, and there is a 
>> large amount of cosmetic work to do to make it more maintainable, but 
>> it should generally work, at least as well as the vendor driver does.
>>
>>     While this is in pre-submission cleanup mode, the latest 
>> standalone source tarball and patch (currently against 2.6.23) will be 
>> available here:
>>
>> http://people.redhat.com/csnook/atl2/
>>
>>     If you have atl2 hardware, please give this a spin.  I plan to 
>> submit the driver for merging some time in the next month or so.  
>> Questions, comments, patches welcome.
> 
> Why not update atl1 for this new hardware?  Why is a new driver needed?
> 
>     Jeff

They have some common hardware at the PCIe level, but at the ethernet level it's 
totally different (simple, low-power 100 Mb vs. Gb with all the bells and 
whistles).  We'd end up special-casing all over the place, because they have 
rather different capabilities, like, say, if we tried to merge ixgb and e1000 
(which have a lot of code in common).  It could be done, but I don't think it 
would be beneficial.  If Atheros decides to maintain the in-tree drivers 
directly, and wants to take it in that direction, I won't object, but from where 
I sit, on the other side of the planet from the guys with the chips hooked up to 
the hardware analyzers, separate drivers seems less painful.

	-- Chris
