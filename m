From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next 1/2] ipv4: add forwarding_uses_pmtu knob to
 protect forward path to use pmtu info
Date: Mon, 6 Jan 2014 10:05:21 +0100
Message-ID: <20140106090521.GQ31491@secunet.com>
References: <20131220130822.GD32129@order.stressinduktion.org>
 <20131231042840.GC27636@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, eric.dumazet@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:45131 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753026AbaAFJFY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 04:05:24 -0500
Content-Disposition: inline
In-Reply-To: <20131231042840.GC27636@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 31, 2013 at 05:28:40AM +0100, Hannes Frederic Sowa wrote:
> Hi Steffen!
> 
> On Fri, Dec 20, 2013 at 02:08:22PM +0100, Hannes Frederic Sowa wrote:
> > Provide a mode where the forwarding path does not use the protocol path
> > MTU to calculate the maximum size for a forwarded packet but instead
> > uses the interface or the per-route locked MTU.
> > 
> > It is easy to inject bogus or malicious path mtu information which
> > will cause either unneeded fragmentation-needed icmp errors (in case
> > of DF-bit set) or unnecessary fragmentation of packets (by default down
> > to min_pmtu). This could be used to either create blackholes on routers
> > (if the generated DF-bit gets dropped later on) or to leverage attacks
> > on fragmentation.
> > 
> > Forwarded skbs are marked with IPSKB_FORWARDED in ip_forward. This flag
> > was introduced for multicast forwarding, but as it does not conflict with
> > our usage in the unicast code path it is perfect for reuse.
> > 
> > I moved the functions ip_sk_accept_pmtu, ip_sk_use_pmtu and ip_skb_dst_mtu
> > along with the new ip_dst_mtu_secure to net/ip.h to fix circular
> > dependencies because of IPSKB_FORWARDED.
> 
> IIRC you have a (semi-)automatic test suite to test for (p)mtu problems? Would
> these checks cover such a change?
> 

I'm currenlty testing these patches. ipv4 looks good but on
ipv6 with 'ping6' the packet size is not reduced according
to the pmtu when forward_use_pmtu is set to 0.

I'll run the tests again with your updated v3 patches.
