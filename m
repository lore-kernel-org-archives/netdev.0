From: "Perla, Sathya" <Sathya.Perla@Emulex.Com>
Subject: RE: [net-next PATCH 4/5] be2net: get rid of AMAP_SET/GET macros in
 TX path
Date: Fri, 28 Sep 2012 07:05:27 +0000
Message-ID: <CF9D1877D81D214CB0CA0669EFAE020C65638C@CMEXMB1.ad.emulex.com>
References: <92de1988-73db-4864-bf19-10ed11dac557@CMEXHTCAS2.ad.emulex.com>
	<20120927.222900.1633352325278735069.davem@davemloft.net>
	<CF9D1877D81D214CB0CA0669EFAE020C6562EE@CMEXMB1.ad.emulex.com>
 <20120928.024034.1426515423229309957.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:58454 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753330Ab2I1HF2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 03:05:28 -0400
In-Reply-To: <20120928.024034.1426515423229309957.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>
>> endianness is handled even in this patch. The call to wrb_fill_hdr()
>> is followed by be_dws_cpu_to_le() to handle this.
>
>That swap_dws() thing is the most inefficient thing I've ever seen.
>
>Instead of being able to benefit from compile time optimizations
>such as byte swaps of constants, you do everything hidden from the
>compiler so nothing gets optimized.

I'd like to clarify that swap_dws() was being used/needed even in the old code. 
The AMAP_SET_BITS() macros (that this patch removes) did nothing to take care of endian byte-swapping.
They are just calculating the mask/shift values of each bit-field and setting the value
in host-endian.

But, as you are convinced that this patch doesn't provide much value, I'll just drop it and 
re-send the patch set....
