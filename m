From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH] sysctl: ipv6: use correct net in ipv6_sysctl_rtcache_flush
Date: Wed, 02 Mar 2011 17:38:23 +0100
Message-ID: <4D6E727F.6090600@free.fr>
References: <1298612883-18762-1-git-send-email-lucian.grijincu@gmail.com> <4D6DB89E.6010709@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:58432 "EHLO smtp5-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755722Ab1CBQid (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 11:38:33 -0500
In-Reply-To: <4D6DB89E.6010709@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/02/2011 04:25 AM, Shan Wei wrote:
> Lucian Adrian Grijincu wrote, at 02/25/2011 01:48 PM:
>> Before this patch issuing these commands:
>>
>>    fd = open("/proc/sys/net/ipv6/route/flush")
>>    unshare(CLONE_NEWNET)
>>    write(fd, "stuff")
>>
>> would flush the newly created net, not the original one.
>
> After appling your patch, when excuting above commands,
> router cache still not be flushed in init net namespace.
> But IPv4 is ok.
>
> Host1:                   Host2
> ping6 Host2
>                          (shell1)
> 			open(/proc/sys/net/ipv6/route/flush)
> 			unshare(CLONE_NEWNET)
> 			while(1) {write(fd, "stuff")}
>
>
> 			(shell2)
>                          ip -6 route show cache<==1*
> 			1*: IPv6 will show one route cache entry.
> 			    But IPv4 shows nothing.
>
> As changlog said, after this patch, shell1 only fulsh the original
> net namespace, not the newly created one. But from shell2, we
> can see that IPv6 route cache is not flushed.
>
> Have i missed something?

Yes, you are right you shouldn't see any route from shell2.
Are you sure 'ip -6 route show cache' does not show the route cache in a 
window where ping6 created a new route and 'write(fd, "stuff")' did not 
flushed the new route yet ?
