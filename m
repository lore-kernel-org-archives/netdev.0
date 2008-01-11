From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [klibc] [patch] import socket defines
Date: Thu, 10 Jan 2008 22:41:36 -0800
Message-ID: <47870FA0.2010509@zytor.com>
References: <477AF86E.1080309@zytor.com> <477BD374.6060506@zytor.com> <20080110.221615.188955433.davem@davemloft.net> <200801110123.38406.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	klibc@zytor.com
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:38842 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbYAKGqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 01:46:21 -0500
In-Reply-To: <200801110123.38406.vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mike Frysinger wrote:
> On Friday 11 January 2008, David Miller wrote:
>> From: "H. Peter Anvin" <hpa@zytor.com>
>>> Seems the most logical thing to do would be to break out the small
>>> portion that everyone wants into <linux/sockaddr.h> or somesuch, and
>>> then remove those ifdefs entirely.
>>>
>>> Proposed patch (still being tested) attached...
>> I think this would clearly break existing glibc builds.
>>
>> I agree with fixing the ifdef checks, but not like this.
> 
> how ?  the large crap in linux/socket.h never made it into glibc builds, and 
> the few things at the top which were relocated to linux/sockaddr.h are still 
> pulled in via linux/socket.h.  for glibc, the resulting '#include 
> <linux/socket.h>' should be unchanged.

The problem is that there isn't any way to do this without breaking 
*something*, since the fundamental problem is that userspace doesn't ask 
for what it wants, so the kernel is expected to "figure it out."

We can either change the way glibc includes the kernel headers, or the 
way everything else does.  The latter should really include the kernel, 
although there is the hack of

/* linux/socket.h */

/* sockaddr stuff */

#ifdef __KERNEL__
# include <linux/socket2.h>
#endif

The reason I went the direction I did was that it looked like the end 
result was cleaner.

	-hpa
