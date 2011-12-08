From: Li Wei <lw@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: Fix for adding multicast route for loopback device
 automatically.
Date: Thu, 08 Dec 2011 08:58:21 +0800
Message-ID: <4EE00BAD.3010409@cn.fujitsu.com>
References: <4EDF1481.1080106@cn.fujitsu.com> <20111207.150615.181825066035193136.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63279 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754287Ab1LHA6L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Dec 2011 19:58:11 -0500
In-Reply-To: <20111207.150615.181825066035193136.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Li Wei <lw@cn.fujitsu.com>
> Date: Wed, 07 Dec 2011 15:23:45 +0800
> 
>> There is no obvious reason to add a default multicast route for loopback
>> devices, otherwise there would be a route entry whose dst.error set to
>> -ENETUNREACH that would blocking all multicast packets.
>>
>> Signed-off-by: Li Wei <lw@cn.fujitsu.com>
> 
> I still do not understand the purpose of this change, what problems
> does the current behavior cause?

Hi, David, thank you for your comment.

The problem is that the resulting routing table depends on the sequence
of interface's initialization and in some situation, that would block all
muticast packets. Suppose there are two interfaces on my computer
(lo and eth0), if we initailize 'lo' before 'eth0', the resuting routing
table(for multicast) would be

# ip -6 route show | grep ff00::
unreachable ff00::/8 dev lo metric 256 error -101
ff00::/8 dev eth0 metric 256

When sending multicasting packets, routing subsystem will return the first
route entry which with a error set to -101(ENETUNREACH).

I know the kernel will set the default ipv6 address for 'lo' when it is up
and won't set the default multicast route for it, but there is no reason to
stop 'init' program from setting address for 'lo', and that is exactly what
systemd did.

I am sure there is something wrong with kernel or systemd, currently I preferred
kernel caused this problem.

> 
> And can you be sure that by making this change, you are not breaking
> something, somewhere, that depends upon the current behavior?
> 
> 

I can't see there is any reason to set a default multicast route for loopback device
*automatically*. 

Thanks, 
Wei
