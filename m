From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv4 tunnels: why IP-IP and SIT enforce DF bit, but GRE does not?
Date: Tue, 01 Dec 2015 11:15:29 +0100
Message-ID: <1448964929.3305540.454487369.098BD535@webmail.messagingengine.com>
References: <56574F32.6070706@shemyak.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Konstantin Shemyak <konstantin@shemyak.com>,
	netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:38059 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755916AbbLAKPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 05:15:30 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id CF30120FBD
	for <netdev@vger.kernel.org>; Tue,  1 Dec 2015 05:15:29 -0500 (EST)
In-Reply-To: <56574F32.6070706@shemyak.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Thu, Nov 26, 2015, at 19:28, Konstantin Shemyak wrote:
> The kernel has taken the decision to always enforce DF bit on IPv4 
> tunnels, which have fixed (not inherited) TTL (e.g. 
> net/ipv4/ipip.c:ipip_tunnel_ioctl()). Commment by Alexey Kuznetsov in 
> the head of ip_gre.c explains that the reason is attempting to avoid 
> network loops.
> 
> But the commit c54419321455631 removed this enforcing from GRE tunnels,
> not changing this behavior for IP-IP (net/ipv4/ipip.c) and SIT 
> (net/ipv6/sit.c).
> 
> It can be discussed whether such enforcing of DF bit is exactly the
> desired behavior, but shouldn't it at least be identical across IPv4 
> tunnels?

Very simple, I would like to see DF bit being enforced in case we have a
static TTL. Parvin, any reasons you removed this code? It is currently
the only way to make sure the network does not kill itself in an endless
loop on configuration mistakes.

Thanks for noticing,
Hannes
