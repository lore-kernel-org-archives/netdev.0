From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 1/2] ipv4: add forwarding_uses_pmtu knob to protect forward path to use pmtu info
Date: Tue, 31 Dec 2013 05:28:40 +0100
Message-ID: <20131231042840.GC27636@order.stressinduktion.org>
References: <20131220130822.GD32129@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, davem@davemloft.net
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:59858 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751620Ab3LaE2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Dec 2013 23:28:41 -0500
Content-Disposition: inline
In-Reply-To: <20131220130822.GD32129@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steffen!

On Fri, Dec 20, 2013 at 02:08:22PM +0100, Hannes Frederic Sowa wrote:
> Provide a mode where the forwarding path does not use the protocol path
> MTU to calculate the maximum size for a forwarded packet but instead
> uses the interface or the per-route locked MTU.
> 
> It is easy to inject bogus or malicious path mtu information which
> will cause either unneeded fragmentation-needed icmp errors (in case
> of DF-bit set) or unnecessary fragmentation of packets (by default down
> to min_pmtu). This could be used to either create blackholes on routers
> (if the generated DF-bit gets dropped later on) or to leverage attacks
> on fragmentation.
> 
> Forwarded skbs are marked with IPSKB_FORWARDED in ip_forward. This flag
> was introduced for multicast forwarding, but as it does not conflict with
> our usage in the unicast code path it is perfect for reuse.
> 
> I moved the functions ip_sk_accept_pmtu, ip_sk_use_pmtu and ip_skb_dst_mtu
> along with the new ip_dst_mtu_secure to net/ip.h to fix circular
> dependencies because of IPSKB_FORWARDED.

IIRC you have a (semi-)automatic test suite to test for (p)mtu problems? Would
these checks cover such a change?

Maybe your test suite is publicly available so I could test these changes
myself or otherwise could you give them a testdrive? That would be very
helpful.

Thank you,

  Hannes
