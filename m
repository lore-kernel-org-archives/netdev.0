From: Ben Greear <greearb@candelatech.com>
Subject: Re: Problem compiling iproute2 on older systems
Date: Sat, 2 Sep 2017 07:17:28 -0700
Message-ID: <29fe7a44-7086-d31c-6cde-ed39afa4a467@candelatech.com>
References: <bf2c63d1-42cc-7fd3-7d79-945feabda50e@candelatech.com>
 <20170902075523.aton5r4p4bgcupra@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:51924 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752649AbdIBOR3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 10:17:29 -0400
In-Reply-To: <20170902075523.aton5r4p4bgcupra@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/02/2017 12:55 AM, Michal Kubecek wrote:
> On Fri, Sep 01, 2017 at 04:52:20PM -0700, Ben Greear wrote:
>> In the patch below, usage of __kernel_ulong_t and __kernel_long_t is
>> introduced, but that is not available on older system (fedora-14, at least).
>>
>> It is not a #define, so I am having trouble finding a quick hack
>> around this.
>>
>> Any ideas on how to make this work better on older OSs running
>> modern kernels?
>>
>>
>> Author: Stephen Hemminger <stephen@networkplumber.org>  2017-01-12 17:54:39
>> Committer: Stephen Hemminger <stephen@networkplumber.org>  2017-01-12 17:54:39
>> Child:  c7ec7697e3f000359aa317394e6dd972e35c1f84 (Fix build on fedora-14 (and other older systems))
>> Branches: master, remotes/origin/master
>> Follows: v3.10.0
>> Precedes:
>>
>>     add more uapi header files
>>
>>     In order to ensure no backward/forward compatiablity problems,
>>     make sure that all kernel headers used come from the local copy.
>>
>>     Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>>
>> --------------------------- include/linux/sysinfo.h ---------------------------
>> new file mode 100644
>> index 0000000..934335a
>> @@ -0,0 +1,24 @@
>> +#ifndef _LINUX_SYSINFO_H
>> +#define _LINUX_SYSINFO_H
>> +
>> +#include <linux/types.h>
>> +
>> +#define SI_LOAD_SHIFT	16
>> +struct sysinfo {
>> +	__kernel_long_t uptime;		/* Seconds since boot */
>> +	__kernel_ulong_t loads[3];	/* 1, 5, and 15 minute load averages */
>> +	__kernel_ulong_t totalram;	/* Total usable main memory size */
>> +	__kernel_ulong_t freeram;	/* Available memory size */
>> +	__kernel_ulong_t sharedram;	/* Amount of shared memory */
>> +	__kernel_ulong_t bufferram;	/* Memory used by buffers */
>> +	__kernel_ulong_t totalswap;	/* Total swap space size */
>> +	__kernel_ulong_t freeswap;	/* swap space still available */
>> +	__u16 procs;		   	/* Number of current processes */
>> +	__u16 pad;		   	/* Explicit padding for m68k */
>> +	__kernel_ulong_t totalhigh;	/* Total high memory size */
>> +	__kernel_ulong_t freehigh;	/* Available high memory size */
>> +	__u32 mem_unit;			/* Memory unit size in bytes */
>> +	char _f[20-2*sizeof(__kernel_ulong_t)-sizeof(__u32)];	/* Padding: libc5 uses this.. */
>> +};
>> +
>> +#endif /* _LINUX_SYSINFO_H */
>
> I've been already thinking about this a bit. Normally, we would simply
> add the file where __kernel_long_t and __kernel_ulong_t are defined.
> The problem is this is <asm/posix_types.h> which depends on
> architecture - which is the point of these types.
>
> Good thing is iproute2 doesn't actually use struct sysinfo anywhere so
> we don't need to have them defined correctly. One possible workaround
> would therefore be defining them as long and unsigned long. As long as
> we don't use the types anywhere, we would be fine.
>
> Another option would be to replace include/linux/sysinfo.h with an empty
> file. The problem I can see with this is that if someone uses a script
> to refresh all copies of uapi headers automatically, the script would
> have to be aware that it must not update this file and preserve the fake
> empty one.

I just sent a patch that appears to compile on all of my build systems, which are
generally fedora-14 to fedora-24 currently.

I haven't actually tested functionality yet, but if you say it is unused, then
it is very likely to be OK, and even if not, I think it will be fine unless
someone is trying to cross-compile.  And in that case, probably more than one
issue involved...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
