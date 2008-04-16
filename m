From: Tony Battersby <tonyb@cybernetics.com>
Subject: Re: TG3 network data corruption regression 2.6.24/2.6.23.4
Date: Wed, 16 Apr 2008 17:00:41 -0400
Message-ID: <480668F9.7060204@cybernetics.com>
References: <20080415.203108.55491723.davem@davemloft.net> <1551EAE59135BE47B544934E30FC4FC002AABC73@nt-irva-0751.brcm.ad.broadcom.com> <20080416201759.GB19724@localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, gregkh@suse.de,
	linux-kernel@vger.kernel.org
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host64.cybernetics.com ([70.169.137.4]:2891 "EHLO
	mail.cybernetics.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765706AbYDPVAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 17:00:39 -0400
In-Reply-To: <20080416201759.GB19724@localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matt Carlson wrote:
> On Wed, Apr 16, 2008 at 08:40:25AM -0700, Michael Chan wrote:
>   
>> David Miller wrote:
>>
>>     
>>> Matt, skb->mac_header is either a pointer or an integer offset
>>> depending upon whether we are building 32-bit or 64-bit.
>>>
>>> Testing skb->mac_header is therefore wrong, because it's an
>>> offset from a pointer in the 64-bit case and therefore it's
>>> alignment does not indicate correctly the actual final alignment
>>> of skb->head + skb->max_header.
>>>
>>> Therefore you should test skb_mac_header(skb) and cast it with
>>> (unsigned long).
>>>       
>> Isn't it better to test for skb->data?  That's where we tell
>> the hardware to start transmitting.
>>
>>     
>>> Please respin this fix with that correction so I can apply it
>>> and get this bug fixed, thanks!
>>>
>>>
>>>       
>> We think that this problem is unique in Tony's environment because
>> of the PCIE-to-PCI bridge that he is using.  We therefore want to
>> test for that bridge and apply the workaround only when it's present.
>> We've never seen this problem in the last 6 or 7 years during the
>> lifetime of the 5701.
>>
>> We'll try to get this done ASAP.
>>
>> Thanks.
>>     
>
> Tony,
>
> Below is a patch that attempts to limit the workaround to the bridge you
> have on your system.  Can you test it and verify that the workaround is
> still enabled?
>
>
>   

This new patch also passes the test. Thumbs up!

Tested-by: Tony Battersby <tonyb@cybernetics.com>

Tony

