From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [IPV6] RAW: Add checksum default defines for MH.
Date: Wed, 24 Jan 2007 19:39:21 +0900
Message-ID: <45B73759.7040802@linux-ipv6.org>
References: <20070123.221918.35467190.davem@davemloft.net>	<E1H9c3T-0005HA-00@gondolin.me.apana.org.au> <20070123.225953.35016491.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, yoshfuji@linux-ipv6.org,
	takamiya@po.ntts.co.jp, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:39750 "EHLO mail.gomagoma.org"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751129AbXAXKjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jan 2007 05:39:23 -0500
In-Reply-To: <20070123.225953.35016491.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Wed, 24 Jan 2007 17:56:23 +1100
> 
>> David Miller <davem@davemloft.net> wrote:
>>> Did a complete agreement occur that this patch is ok?
>> My only concern is that we're putting an arbitrary list of
>> protocols in the generic raw.c.  What's the justification
>> for including these protocols in particular but not others?
>>
>> Is there any reason why the application can't just use the
>> existing IPV6_CHECKSUM socket option to set the same fields?
> 
> My understanding in the MH case is that the kernel is going
> to make changes to the header that the user can't predict
> and thus it's impossible for them to set the correct checksum.

Yes, kernel will change the IPv6 header address, however,
actually it is possible to compute MH checksum by user-space
since final address (=home address) is seen by application
on both sending and receiving case and the checksum is calculated
by the address. It is true user can use IPV6_CHECKSUM option
to set the same fields.
(FYI, it is failed to validate MH checksum with IPv6 header
address on wire (or before parsing extension headers) for such
Mobile IPv6 routing optimized packet).

So this fix is not mandatory feature for kernel.
This patch just relaxes user application like ICMPv6 case
then we can cancel this if it is too much.

Thanks for taking care of this again, guys.

-- 
Masahide NAKAMURA
