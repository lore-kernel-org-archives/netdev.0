From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] [PATCH] Optimize TCP sendmsg in favour of fast devices?
Date: Fri, 29 Jan 2010 11:56:04 -0800
Message-ID: <4B633D54.7030200@hp.com>
References: <20100121.012520.254679483.davem@davemloft.net>	<20100121094157.GA15262@gondor.apana.org.au>	<OF7EA723DA.DC2FF4FC-ON652576B8.002064CB-652576B8.00267739@in.ibm.com>	<20100129090625.GD23140@gondor.apana.org.au> <OFA813CB35.7FC6144E-ON652576BA.003C3B2C-652576BA.003CB215@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:24019 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754534Ab0A2T4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 14:56:08 -0500
In-Reply-To: <OFA813CB35.7FC6144E-ON652576BA.003C3B2C-652576BA.003CB215@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krishna Kumar2 wrote:
>>Herbert Xu <herbert@gondor.apana.org.au> wrote on 01/29/2010 02:36:25 PM:
>>
>>
>>>I ran 5 serial netperf's with 16K and another 5 serial netperfs
>>>with 64K I/O sizes, and the aggregate result is:
>>>
>>>0. Driver unsets F_SG but sets F_GSO:
>>>      Original code with 16K: 19471.65
>>>      New code with 16K:      19409.70
>>>      Original code with 64K: 21357.23
>>>      New code with 64K:      22050.42
>>
>>OK this is more in line with what I was expecting, namely that
>>enabling GSO is actually beneficial even without SG.
>>
>>It would be good to get the CPU utilisation figures so we can
>>see the complete picture.
> 
> 
> Same 5 runs of single netperf's:
> 
> 0. Driver unsets F_SG but sets F_GSO:
>         Org (16K):      BW: 18180.71    SD: 13.485
>         New (16K):      BW: 18113.15    SD: 13.551
>         Org (64K):      BW: 21980.28    SD: 10.306
>         New (64K):      BW: 21386.59    SD: 10.447
> 
> 1. Driver unsets F_SG, and with GSO off
>         Org (16K):      BW: 10894.62    SD: 26.591
>         New (16K):      BW: 7262.10     SD: 35.340
>         Org (64K):      BW: 12396.41    SD: 23.357
>         New (64K):      BW: 7853.02     SD: 32.405
> 
> 
> 2. Driver unsets F_SG and uses ethtool to set GSO:
>         Org (16K):      BW: 18094.11    SD: 13.603
>         New (16K):      BW: 17952.38    SD: 13.743
>         Org (64K):      BW: 21540.78    SD: 10.771
>         New (64K):      BW: 21818.35    SD: 10.598

Just a slight change in service demand there...  For those unfamiliar, 
service demand in netperf is the microseconds of non-idle CPU time per 
KB of data transferred.  Smaller is better.

happy benchmarking,

rick jones
