From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] sky2: make sure ethernet header is in transmit skb
Date: Mon, 04 Jan 2010 12:02:24 -0500
Message-ID: <4B421F20.6020202@majjas.com>
References: <20091226140544.5600b3d1@nehalam>
 <20091226.194418.229766965.davem@davemloft.net>
 <20091226.201107.35060733.davem@davemloft.net>
 <20100103.213258.263977883.davem@davemloft.net>
 <20100104084049.4d9cd0e4@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta4.srv.hcvlny.cv.net ([167.206.4.199]:46134 "EHLO
	mta4.srv.hcvlny.cv.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751860Ab0ADRDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 12:03:08 -0500
In-reply-to: <20100104084049.4d9cd0e4@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/4/2010 11:40 AM, Stephen Hemminger wrote:
> On Sun, 03 Jan 2010 21:32:58 -0800 (PST)
> David Miller<davem@davemloft.net>  wrote:
>
>    
>> From: David Miller<davem@davemloft.net>
>> Date: Sat, 26 Dec 2009 20:11:07 -0800 (PST)
>>
>>      
>>> From: David Miller<davem@davemloft.net>
>>> Date: Sat, 26 Dec 2009 19:44:18 -0800 (PST)
>>>
>>>        
>>>> From: Stephen Hemminger<shemminger@linux-foundation.org>
>>>> Date: Sat, 26 Dec 2009 14:05:44 -0800
>>>>
>>>>          
>>>>> Other drivers may have same problem, I really think this ought
>>>>> to be done at higher level.
>>>>>            
>>>> I tend to agree with you, and I thought we had handled all
>>>> cases.  Let's simply make AF_PACKET linearize the link
>>>> level header before sending things out to the transmit path.
>>>>
>>>> I can work on this if you want.
>>>>          
>>> Actually Stephen, I took a look and I can't see how AF_PACKET
>>> can create this situation.
>>>
>>> It always copies into the linear area of the SKB it allocates
>>> for sendmsg() processing.  Whether the data comes from sendmsg
>>> data or the mmap() ring buffer.
>>>        
>> Stephen can you get a backtrace of the code path which triggers
>> this?  I want to fix it at a higher level too, but I can't
>> do that until I know where it actually happens.
>>      
> Ignore it, the problem is outside the sky2 driver in some other
> place causing corrupt skb's. I never reproduced this (with added BUG_ON
> and WARN_ON), only seen by Michael.
>    
I've posted several oops with explanations:
http://lkml.org/lkml/2009/12/5/60
http://lkml.org/lkml/2009/12/21/268
http://lkml.org/lkml/2009/12/23/316

In a nutshell, my system was hanging (sometimes with a viewable oops, 
sometimes not (unrelated KMS issues). The hangs (with watchdog reboot) 
happened when under load and when any attached device sent in a DHCP 
request/offer.

The hang was 100% reproducible when running Microsoft Backup vrom a win7 
box via SAMBA onto the affected server. Stephen's patch stopped the hang 
and oops.

Please let me know what I can do to help.

Under the same load conditions (but no longer associated with DHCP) I'm 
now seeing multiple soft interrupt errors coming from sky2. This seems 
to be a race condition somewhere as it only occurs when a mingetty is 
run on tty1 prior to generating load on the sky2 driver. It could be a 
wild goose chase, but I think something is getting corrupted by either 
devpts or console when mingetty issues a vhangup on pts0.



