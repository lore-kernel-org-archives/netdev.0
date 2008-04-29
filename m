From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC XFRM]: esp: fix scatterlist of out bounds access with crypto_eseqiv
Date: Tue, 29 Apr 2008 16:04:55 +0200
Message-ID: <48172B07.8050401@trash.net>
References: <48161D99.5070303@trash.net> <20080429014107.GA16700@gondor.apana.org.au> <4816AD93.5090404@trash.net> <20080429135932.GA20790@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-crypto@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54624 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751880AbYD2OE7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 10:04:59 -0400
In-Reply-To: <20080429135932.GA20790@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Tue, Apr 29, 2008 at 07:09:39AM +0200, Patrick McHardy wrote:
>   
>> I've attached two traces, the one from eseqiv and a similar
>> one from authenc (I've manually overriden eseqiv by chainiv
>> to test whether its responsible for the broken packets I was
>> seeing, which turned out to be the case. I'll look into that).
>>     
>
> Thanks, looks like I left out the sg_is_last check in restoring
> adding scatterwalk_sg_next.  Worse yet, eseqiv doesn't even
> encrypt the last block.  It's a good thing the hifn driver doesn't
> work yet :)

Thanks for looking into this, the eseqiv problem is exactly the one
I'm seeing :) I'll test your patch and let you know the results.
