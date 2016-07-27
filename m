From: arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: Re: [v3] UCC_GETH/UCC_FAST: Use IS_ERR_VALUE_U32 API to avoid
 IS_ERR_VALUE abuses.
Date: Wed, 27 Jul 2016 22:37:02 +0530
Message-ID: <5798EA36.70000@gmail.com>
References: <1469297151-9763-1-git-send-email-arvind.yadav.cs@gmail.com>
 <4175803.I7CDUloLxQ@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: zajec5@gmail.com, leoli@freescale.com, qiang.zhao@freescale.com,
	viresh.kumar@linaro.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, scottwood@freescale.com,
	akpm@linux-foundation.org, linux@roeck-us.net
To: Arnd Bergmann <arnd@arndb.de>, linuxppc-dev@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33922 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754303AbcG0RHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 13:07:08 -0400
In-Reply-To: <4175803.I7CDUloLxQ@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am also agree with Arnd Bergmann. We should use 'static inline function'
instead of macro to deal with error check.

On Tuesday 26 July 2016 05:09 PM, Arnd Bergmann wrote:
> On Saturday, July 23, 2016 11:35:51 PM CEST Arvind Yadav wrote:
>> diff --git a/include/linux/err.h b/include/linux/err.h
>> index 1e35588..a42f942 100644
>> --- a/include/linux/err.h
>> +++ b/include/linux/err.h
>> @@ -19,6 +19,7 @@
>>   #ifndef __ASSEMBLY__
>>   
>>   #define IS_ERR_VALUE(x) unlikely((unsigned long)(void *)(x) >= (unsigned long)-MAX_ERRNO)
>> +#define IS_ERR_VALUE_U32(x) unlikely((unsigned int)(x) >= (unsigned int)-MAX_ERRNO)
>>   
>>   static inline void * __must_check ERR_PTR(long error)
>>   {
> This doesn't really look like something we want to have as a generic
> interface. The IS_ERR_VALUE() API is rather awkward already, and your
> use seems specific to the cpu_muram_alloc() function.
>
> How about something like
>
> int cpm_muram_error(unsigned long addr)
> {
> 	if (addr >= (unsigned long)-MAX_ERRNO)
> 		return addr;
> 	else
> 		return 0;
> }
>
> and then use that to check the value returned by the allocation
> that is still an 'unsigned long', before assigning it to a 'u32'.
>
> 	Arnd
