From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] Fix build on fedora-14 (and other older systems)
Date: Sun, 3 Sep 2017 11:28:20 -0700
Message-ID: <7cdfe2a6-9235-ce67-e5d6-db39ed03c936@candelatech.com>
References: <1504361702-30266-1-git-send-email-greearb@candelatech.com>
 <20170903085004.5b5ded4f@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:55638 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751287AbdICS2W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 14:28:22 -0400
In-Reply-To: <20170903085004.5b5ded4f@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/03/2017 08:50 AM, Stephen Hemminger wrote:
> On Sat,  2 Sep 2017 07:15:02 -0700
> greearb@candelatech.com wrote:
>
>> diff --git a/include/linux/sysinfo.h b/include/linux/sysinfo.h
>> index 934335a..3596b02 100644
>> --- a/include/linux/sysinfo.h
>> +++ b/include/linux/sysinfo.h
>> @@ -3,6 +3,14 @@
>>
>>  #include <linux/types.h>
>>
>> +/* So we can compile on older OSs, hopefully this is correct. --Ben */
>> +#ifndef __kernel_long_t
>> +typedef long __kernel_long_t;
>> +#endif
>> +#ifndef __kernel_ulong_t
>> +typedef unsigned long __kernel_ulong_t;
>> +#endif
>> +
>>  #define SI_LOAD_SHIFT	16
>>  struct sysinfo {
>>  	__kernel_long_t uptime;		/* Seconds since boot */
>
> I am not accepting this patch because all files in include/linux are automatically
> regenerated from kernel 'make install_headers'. No exceptions. If you want to change
> a header in include/linux it has to go through upstream kernel inclusion.

It would be wrong to add this to the actual kernel header I think.

Do you have another suggestion for fixing iproute2 compile?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
