From: Ben Greear <greearb@candelatech.com>
Subject: Re: Commit 1fe8e0... (include more headers in if_tunnel.h) breaks my
 user-space build.
Date: Fri, 13 Jan 2017 11:50:32 -0800
Message-ID: <6c983e7e-dbb3-3542-ffed-95f4d2f3c5bc@candelatech.com>
References: <f1cede01-3fa4-130a-fa2d-7cbdfe3648b3@candelatech.com>
 <20170113114158.6e5c3461@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>, mikko.rapeli@iki.fi
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:54292 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750923AbdAMTud (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 14:50:33 -0500
In-Reply-To: <20170113114158.6e5c3461@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/2017 11:41 AM, Stephen Hemminger wrote:
> On Fri, 13 Jan 2017 11:12:32 -0800
> Ben Greear <greearb@candelatech.com> wrote:
>
>> I am including netinet/ip.h, and also linux/if_tunnel.h, and the linux/ip.h conflicts with
>> netinet/ip.h.
>>
>> Maybe my build environment is screwed up, but maybe also it would be better to
>> just let the user include appropriate headers before including if_tunnel.h
>> and revert this patch?
>>
>>
>> include/uapi/linux/if_tunnel.h: include linux/if.h, linux/ip.h and linux/in6.h
>>
>>      Fixes userspace compilation errors like:
>>
>>      error: field ‘iph’ has incomplete type
>>      error: field ‘prefix’ has incomplete type
>>
>>      Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
>>      Signed-off-by: David S. Miller <davem@davemloft.net>
>>
>> Thanks,
>> Ben
>>
>
> What I ended up doing for iproute2 was including all headers used by the source
> based on sanitized kernel headers.  Basically
>   $ git grep '^#include <linux/' | \
> 	awk -F: '{print $2}' | \
> 	sed -e 's/^#include <//' -e 's/>.*$//' | \
> 	sort -u >linux.headers
>    $ for f in $(cat linux.headers)
>      do cp ~/kernel/net-next/usr/include/$f include/$f
>      done
>
> You can't take only some of the headers, once you decide to diverge from glibc provided
> headers, you got to take them all.
>

I do grab a copy of the linux kernel headers and compile against that, but netinet/ip.h is
coming from the OS.  Do you mean I should not include netinet/ip.h and instead use linux/ip.h?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
