From: Patrick McHardy <kaber@trash.net>
Subject: Re: IPsec replay sequence number overflow behavior? (RFC4303 section
 3.3.3)
Date: Mon, 10 Dec 2007 04:16:36 +0100
Message-ID: <475CAF94.7020306@trash.net>
References: <E1J1Bfw-0006Kw-00@gondolin.me.apana.org.au> <200712090937.56599.paul.moore@hp.com> <20071210030653.GA31566@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Moore <paul.moore@hp.com>, netdev@vger.kernel.org,
	latten@us.ibm.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36333 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485AbXLJDQj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Dec 2007 22:16:39 -0500
In-Reply-To: <20071210030653.GA31566@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Sun, Dec 09, 2007 at 09:37:56AM -0500, Paul Moore wrote:
>   
>> Thanks for clearing that up, I'll send a patch this week; complete with an 
>> unlikely (similar to the RFC quality IPsec audit patch I sent on Friday) and 
>> a decrement to the sequence counter in case of rollover.
>>     
>
> Actually I think we should just use the SA expire mechanism
> to do this.  The reason is that the overflow we want to detect
> only applies to 32-bit sequence numbers.  In future we will be
> making our sequence numbers 64-bit.
>
> When we do that we can no longer just check against wrapping
> to zero since we need to know whether ESNs are in use or not.
>
> The easiest fix is to just force the hard_packet_limit to 2^32.
> upon SA creation.

Won't this break with manually installed SAs (without a keying
daemon)?


