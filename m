From: David Miller <davem@davemloft.net>
Subject: Re: Checksum offload queries
Date: Mon, 07 Dec 2015 14:38:48 -0500 (EST)
Message-ID: <20151207.143848.2158761076110518741.davem@davemloft.net>
References: <5665A848.9010001@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48177 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932342AbbLGTiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 14:38:50 -0500
In-Reply-To: <5665A848.9010001@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Mon, 7 Dec 2015 15:39:52 +0000

> 1) Receive checksums.  Given that CHECKSUM_UNNECESSARY conversion
> exists (and is a cheap operation), what is the advantage to the
> stack of using CHECKSUM_COMPLETE if the packet happens to be a
> protocol which CHECKSUM_UNNECESSARY conversion can handle?  As I see
> it, CHECKSUM_UNNECESSARY is strictly better as the stack is told
> "the first csum_level+1 checksums are good" *and* (indirectly) "here
> is the whole-packet checksum, which you can use to help with
> anything beyond csum_level+1".  Is it not, then, best for a device
> only to use CHECKSUM_COMPLETE for protocols the conversion doesn't
> handle?  (I agree that having that fallback of CHECKSUM_COMPLETE is
> a good thing, sadly I don't think our new chip does that.  (But
> maybe firmware can fix it.))

No, it is better to universally provide the 1's complement sum for
all receive packets.  This allows the stack more flexibility in
checksum handling.

> 3) Related to the above, what does a NETIF_F_HW_CSUM device do when
> transmitting an unencapsulated packet (let's say it's UDP)
> currently?  Will it simply get no checksum offload at all?  Will
> csum_start point at the regular UDP checksum (and the stack will do
> the IP header checksum)?  Again, a device that does both HW_ and
> IP_CSUM could cope with this (do the IP and UDP checksums as per
> NETIF_F_IP_CSUM, and just don't ask for a 'generic' HW_CSUM), though
> that would require more checksum flags (there's no way for
> CHECKSUM_PARTIAL to say "do your IP-specific stuff but ignore
> csum_start and friends).

The stack will have skb->csum_start point to the UDP header's checksum
field for unencapsulated packets, and it has done this for decades.

Sun Microsystems had NETIF_F_HW_CSUM supporting NICs nearly two
decades ago, and this is what NETIF_F_HW_CSUM was designed for.
