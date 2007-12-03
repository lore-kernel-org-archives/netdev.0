From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH]: fix lro_gen_skb() alignment
Date: Sun, 02 Dec 2007 19:07:26 -0500
Message-ID: <475348BE.3010203@myri.com>
References: <E1Iy2ey-0005eY-00@gondolin.me.apana.org.au> <475057E4.3000909@myri.com> <ada3aunlf4s.fsf@cisco.com> <4750660F.7000704@myri.com> <20071130223457.GA25388@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>, davem@davemloft.net,
	ossthema@de.ibm.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1902 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750718AbXLCAIP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Dec 2007 19:08:15 -0500
In-Reply-To: <20071130223457.GA25388@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Fri, Nov 30, 2007 at 02:35:43PM -0500, Andrew Gallatin wrote:
>>> Isn't the value of 2 ethernet-specific (to round the 14-byte header up
>>> to 16)?  Given that the rest of the lro code is fairly careful to
>>> calculate mac_hdr_len etc it seems as if it would be cleaner to make
>>> this independent of the specific L2 being used.
>>>
>>> (And I plan on using the LRO module for IP-over-InfiniBand so this is
>>> not completely theoretical)
> 
> Good point!
> 
> We really should rename NET_IP_ALIGN so that both Ethernet and DMA
> occur in it somehow :)
> 
>> Good point.  I tend to think all the world is ethernet.
>> Perhaps the better way would be to simply add an alignment pad
>> field to lro_mgr?  When the driver initializes it, it specifies
>> any padding needed.  Ethernet drivers would specify 2.
> 
> Just pass in the mac_hdr_len, and calculate the padding as

That was my first thought as well, but it turns out that
when lro_gen_skb() is called via the out1 label, mac_hdr_len
may not be known.  It seemed simplest and cleanest to just
make it a field in lro_mgr.

Drew
