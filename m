From: John <linux@8192.net>
Subject: Re: [PATCH] IPv6 transmit hashing for bonding driver
Date: Wed, 18 May 2011 20:25:14 -0700
Message-ID: <4DD48D9A.7050404@8192.net>
References: <4DD30AF2.1090707@8192.net> <26860.1305680256@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp121.dfw.emailsrvr.com ([67.192.241.121]:50597 "EHLO
	smtp121.dfw.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756414Ab1ESDZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 23:25:13 -0400
In-Reply-To: <26860.1305680256@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/17/2011 5:57 PM, Jay Vosburgh wrote:
> 	It would also be useful to include an update bonding.txt to
> describe the IPv6 algorithm; I'd word that something like the following
> (filling in the missing bits) for the layer3+4 section, applying similar
> changes to the layer2+3 section:
>

Thanks for the feedback. This is a good point, I will take care of this too.

>
> 	Style nit: I don't believe the outermost parentheses are
> necessary.  Since you do this twice, perhaps make a small inline
> function to handle it.
>

The outer parenthesis are definitely not required; I will remove those. 
I did speak with Andy Gospodarek about breaking out all of the hashing 
methods into separate functions. I'll give that some more thought.

>
> 	For fragmented datagrams, the above will keep all fragments
> together, which is good, but are there other header types that should be
> skipped over to find the UDP/TCP header for hashing purposes?
>

This is a good question, and I'm not too sure how to proceed. There are 
other headers that can sit between the IPv6 header and the upper 
protocol payload (hop-by-hop, destination options, routing, fragment, 
AH, ESP, mobility), and the current implementation would handle any of 
those being present by ignoring the upper protocol data and only hashing 
on the source and destination IPv6 addresses.

I was trying to avoid loops but one would be required to process the 
headers. Additionally there would need to be code (or a table) that 
knows how to process each header type, and that may require maintenance 
any time a new header option become popular.

It's definitely do-able, though. Any thoughts?

John
