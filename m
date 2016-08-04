From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPIP tunnel with fixed TTL but no DF bit
Date: Thu, 4 Aug 2016 12:25:41 +0200
Message-ID: <33dfec52-46c0-7eca-11f3-934a99fa54cc@stressinduktion.org>
References: <1b4cfd95-4242-c0a6-7cd4-43fa037e2bae@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com
To: Alexander Heinlein <alexander.heinlein@secunet.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:52546 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757194AbcHDKdE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 06:33:04 -0400
In-Reply-To: <1b4cfd95-4242-c0a6-7cd4-43fa037e2bae@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 04.08.2016 08:20, Alexander Heinlein wrote:
> I would like to know why ip_tunnel_ioctl() enforces the DF bit whenever
> the tunnel device has a fixed TTL set. The same restriction is enforced
> by iproute2 (iptunnel.c and link_iptnl.c).
> 
> Ideally I would like to use an IPIP tunnel with a fixed TTL but no DF
> bit set. Otherwise for non-TCP packets that are larger than the PMTU
> size the kernel will send ICMP packets to end systems. However these
> ICMP packets are ignored by the end system since the original packets
> didn't have the DF bit set. As a result, non-TCP packets larger than the
> PMTU are being dropped.

It should prevent endless loops. Imagine you have a packet looping into
the tunnel again somehow because of broken network setup: the tie
breaker normally is the TTL, so if it reaches zero, the packet gets
dropped. You can do the same with the packet size. So you add yet
another tunnel header, until you can't forward it anymore and thus drop
the packet, too.

If you don't use any of those tie breakers you are vulnerable to network
outages.

Bye,
Hannes
