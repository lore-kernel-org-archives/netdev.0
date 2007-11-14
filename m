From: Hideo AOKI <haoki@redhat.com>
Subject: Re: [PATCH 2/5] accounting unit and variable
Date: Wed, 14 Nov 2007 10:32:26 -0500
Message-ID: <473B150A.8050208@redhat.com>
References: <47264F3E.3080306@redhat.com>	<20071109123420.GD27984@gondor.apana.org.au>	<473A6B11.7090208@redhat.com> <20071113.195549.181119456.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, satoshi.oshima.fk@hitachi.com,
	andi@firstfloor.org, shemminger@linux-foundation.org,
	johnpol@2ka.mipt.ru, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com
To: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53559 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754156AbXKNPj3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 10:39:29 -0500
In-Reply-To: <20071113.195549.181119456.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Hideo AOKI <haoki@redhat.com>
> Date: Tue, 13 Nov 2007 22:27:13 -0500
> 
>> Herbert Xu wrote:
>>> On Mon, Oct 29, 2007 at 05:23:10PM -0400, Hideo AOKI wrote:
>>>>  
>>>> +#define SK_DATAGRAM_MEM_QUANTUM ((int)PAGE_SIZE)
>>>> +
>>>> +static inline int sk_datagram_pages(int amt)
>>>> +{
>>>> +	return DIV_ROUND_UP(amt, SK_DATAGRAM_MEM_QUANTUM);
>>>> +}
>>> Does this really have to be int? Unsigned would let the compiler
>>> optimise this to a simple shift.
>> Thank you for the comment.
>>
>> This inline function is used to calculate the first argument of atomic_add()
>> and atomic_sub(). Since the argument is int, I believe that using int is
>> better than using unsigned int.
> 
> If you know the values will always be positive, as you will know here,
> it is OK to us unsigned int here and avoids the unacceptable expensive
> divide instruction.
> 
> Please fix this.

Hello,

Thanks for your comments. I finally understood.

I'll fix it and resubmit the patch as soon as possible.

Regards,
Hideo

--
Hitachi Computer Products (America) Inc.

