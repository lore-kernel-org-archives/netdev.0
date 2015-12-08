From: Edward Cree <ecree@solarflare.com>
Subject: Re: Checksum offload queries
Date: Tue, 8 Dec 2015 14:42:19 +0000
Message-ID: <5666EC4B.40800@solarflare.com>
References: <5665A848.9010001@solarflare.com>
 <20151207.143848.2158761076110518741.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, Tom Herbert <tom@herbertland.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:57210 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752019AbbLHOm2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 09:42:28 -0500
In-Reply-To: <20151207.143848.2158761076110518741.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/15 19:38, David Miller wrote:
> No, it is better to universally provide the 1's complement sum for
> all receive packets.  This allows the stack more flexibility in
> checksum handling.
I'm afraid I still don't see it.  If a device can both provide the 1's complement sum _and_ validate some of the checksums in the packet, that should be strictly better than just providing the 1's complement sum - the stack has at least as much information, and less work to do.  And while there is no general way at present for a driver to tell the stack it has done both (and in my opinion there should be such a way), it _is_ possible in the specific case of a UDP packet with the checksum filled in, thanks to CHECKSUM_UNNECESSARY conversion.  So why shouldn't a device (that otherwise gives the full ones complement sum with CHECKSUM_COMPLETE) use CHECKSUM_UNNECESSARY in this specific case?  Is there a flaw in my logic, or is it just that this would be a hack and the Right Thing is to change 
 the interface to let a driver report both pieces of information *directly*?  Or am I wrong for some other reason?
>> 3) Related to the above, what does a NETIF_F_HW_CSUM device do when
>> transmitting an unencapsulated packet
> The stack will have skb->csum_start point to the UDP header's checksum
> field for unencapsulated packets, and it has done this for decades.
>
> Sun Microsystems had NETIF_F_HW_CSUM supporting NICs nearly two
> decades ago, and this is what NETIF_F_HW_CSUM was designed for.
Thanks, that makes more sense now.  Though, does that mean that there's no way in this case to offload the IP header checksum?  (Of course, it's generally much less work than the payload checksum, and it goes away in v6.)
