From: Konstantin Shemyak <konstantin@shemyak.com>
Subject: Re: IPv4 tunnels: why IP-IP and SIT enforce DF bit, but GRE does not?
Date: Tue, 1 Dec 2015 15:20:54 +0200
Message-ID: <565D9EB6.1080102@shemyak.com>
References: <56574F32.6070706@shemyak.com>
 <1448964929.3305540.454487369.098BD535@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sub3.mail.dreamhost.com ([69.163.253.7]:59510 "EHLO
	homiemail-a15.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752541AbbLANU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 08:20:59 -0500
In-Reply-To: <1448964929.3305540.454487369.098BD535@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01.12.2015 12:15, Hannes Frederic Sowa wrote:
> Hello,
>
> On Thu, Nov 26, 2015, at 19:28, Konstantin Shemyak wrote:
>> The kernel has taken the decision to always enforce DF bit on IPv4
>> tunnels, which have fixed (not inherited) TTL (e.g.
>> net/ipv4/ipip.c:ipip_tunnel_ioctl()). Commment by Alexey Kuznetsov in
>> the head of ip_gre.c explains that the reason is attempting to avoid
>> network loops.
>>
>> But the commit c54419321455631 removed this enforcing from GRE tunnels,
>> not changing this behavior for IP-IP (net/ipv4/ipip.c) and SIT
>> (net/ipv6/sit.c).
>>
>> It can be discussed whether such enforcing of DF bit is exactly the
>> desired behavior, but shouldn't it at least be identical across IPv4
>> tunnels?
>
> Very simple, I would like to see DF bit being enforced in case we have a
> static TTL. Parvin, any reasons you removed this code? It is currently
> the only way to make sure the network does not kill itself in an endless
> loop on configuration mistakes.

This solution does not completely eliminate all network loops, as there 
may be other routers in the loop which do not set the DF bit. But it is 
true that this behavior is "we did all we could".
My point was not to question its feasibility, but to make it similar 
across GRE, IP-IP and SIT tunnels.

Konstantin.
