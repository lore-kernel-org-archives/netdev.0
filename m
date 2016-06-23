From: Blair Steven <Blair.Steven@alliedtelesis.co.nz>
Subject: Re: esp: Fix ESN generation under UDP encapsulation
Date: Thu, 23 Jun 2016 04:25:21 +0000
Message-ID: <576B64B1.9030000@alliedtelesis.co.nz>
References: <20160612234814.15460-1-blair.steven@alliedtelesis.co.nz>
 <20160613102024.GX7698@gauss.secunet.com>
 <5760A501.3070504@alliedtelesis.co.nz>
 <20160617102429.GH7698@gauss.secunet.com>
 <20160618050336.GA12205@gondor.apana.org.au>
 <20160620105934.GL7698@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:59912 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785AbcFWEZ1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 00:25:27 -0400
Received: from mmarshal3.atlnz.lc (mmarshal3.atlnz.lc [10.32.18.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(Client did not present a certificate)
	by gate2.alliedtelesis.co.nz (Postfix) with ESMTPS id AD9108604B
	for <netdev@vger.kernel.org>; Thu, 23 Jun 2016 16:25:24 +1200 (NZST)
In-Reply-To: <20160620105934.GL7698@gauss.secunet.com>
Content-Language: en-US
Content-ID: <FFB91A362D2BD74E9F49C0D2FAEF2D14@atlnz.lc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change tests okay in my setup.

Thanks very much
-Blair

On 06/20/2016 10:59 PM, Steffen Klassert wrote:
> On Sat, Jun 18, 2016 at 01:03:36PM +0800, Herbert Xu wrote:
>> On Fri, Jun 17, 2016 at 12:24:29PM +0200, Steffen Klassert wrote:
>>> On Wed, Jun 15, 2016 at 12:44:54AM +0000, Blair Steven wrote:
>>>> The restoration is happening - but being actioned on the wrong location.
>>>>
>>>> The destination IP address is being saved and restored, and the SPI
>>>> being written directly after the destination IP address. From my
>>>> understanding though, the ESN shuffling should have saved and restored
>>>> the UDP source / dest ports + SPI.
>>> Yes, looks like we copy with a wrong offset if udp encapsulation
>>> is used, skb_transport_header() does not point to the esp header
>>> in this case. Ccing Herbert, he changed this part when switching
>>> to the new AEAD interface with
>>> commit 7021b2e1cddd ("esp4: Switch to new AEAD interface").
>> Thanks for catching this!
>>
>> I think rather than changing the transport header (which isn't
>> quite right because UDP still is the transport protocol), we can
>> just save the offset locally.  Something like this:
>>
>> ---8<---
>> Blair Steven noticed that ESN in conjunction with UDP encapsulation
>> is broken because we set the temporary ESP header to the wrong spot.
>>
>> This patch fixes this by first of all using the right spot, i.e.,
>> 4 bytes off the real ESP header, and then saving this information
>> so that after encryption we can restore it properly.
>>
>> Fixes: 7021b2e1cddd ("esp4: Switch to new AEAD interface")
>> Reported-by: Blair Steven <Blair.Steven@alliedtelesis.co.nz>
>> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> Looks good.
> Blair could you please test this?
>
> Thanks!
