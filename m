From: Roy Pledge <Roy.Pledge@freescale.com>
Subject: Re: Socket Buffers and Memory Managment
Date: Wed, 18 Jul 2007 13:13:21 -0400
Message-ID: <469E4A31.6030603@freescale.com>
References: <551531.35231.qm@web82912.mail.mud.yahoo.com> <20070717204129.79e7fe0d@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vinay ravuri <vinaynyc@yahoo.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:64526 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752413AbXGRROA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 13:14:00 -0400
In-Reply-To: <20070717204129.79e7fe0d@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> 
> You could play tricks with skb frags but it would be fragile
> and not worth the trouble. The problem is that the receive
> skb can stay in the system for a really long time (until the application
> reads the data) so your fixed size buffer pool in hardware
> would get exhausted.
>  
Perhaps you could elaborate on why this is considered fragile?  It seems to me 
that as long as proper page management is performed, this mechanism should be 
stable for processing non-contiguous receive buffers.  I agree that 
replenishment needs to be addressed, but I see that as an independent issue from 
using frag lists on receive.

>> Also, if the h/w gives me a single packet in multiple
>> locations (i.e. non-contiguous chunks of memory), can
>> socket buffers handle chains of buffers?  I am looking
>> for a facility like mbuf's in netbsd where one can
>> chain multiple buffers together to make construct a
>> single packet.
> 
> Yes, skb frag list could be used for that but you don't
> want to do that. See above. Copy the data into an new
> skb and reserve any necessary bytes so IP header is
> aligned.  I.e. if using ethernet header (14 bytes), do
> skb_reserve(skb, 2) before copying the data.

But isn't avoiding the copy the point of all this?  With some hardware models 
using skbs as receive buffers is inconvenient and can be wasteful if jumbo 
frames are required.  Wouldn't a mechanism where it is possible to create (or 
populate) an skb from data in a pre existing buffer without copying be more 
general and address more hardware models?  It seems to me that more and more 
hardware is supporting scatter/gather output for received data, but the page* 
model in the frag list can be restrictive in how data is placed before being 
passed into the stack.

Thanks

Roy


