From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v8] bonding: support for IPv6 transmit hashing
Date: Wed, 22 Aug 2012 22:49:43 -0700 (PDT)
Message-ID: <20120822.224943.2003737267167569987.davem@davemloft.net>
References: <2e01d8f94c42c61af9886683a4c35caf6816bc3d.1345610688.git.linux@8192.net>
	<2e01d8f94c42c61af9886683a4c35caf6816bc3d.1345615999.git.linux@8192.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux@8192.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33384 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754470Ab2HWFto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 01:49:44 -0400
In-Reply-To: <2e01d8f94c42c61af9886683a4c35caf6816bc3d.1345615999.git.linux@8192.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Eaglesham <linux@8192.net>
Date: Tue, 21 Aug 2012 23:43:35 -0700

> From: John Eaglesham <linux@8192.net>
> 
> Currently the "bonding" driver does not support load balancing outgoing
> traffic in LACP mode for IPv6 traffic. IPv4 (and TCP or UDP over IPv4)
> are currently supported; this patch adds transmit hashing for IPv6 (and
> TCP or UDP over IPv6), bringing IPv6 up to par with IPv4 support in the
> bonding driver. In addition, bounds checking has been added to all
> transmit hashing functions.
> 
> The algorithm chosen (xor'ing the bottom three quads of the source and
> destination addresses together, then xor'ing each byte of that result into
> the bottom byte, finally xor'ing with the last bytes of the MAC addresses)
> was selected after testing almost 400,000 unique IPv6 addresses harvested
> from server logs. This algorithm had the most even distribution for both
> big- and little-endian architectures while still using few instructions. Its
> behavior also attempts to closely match that of the IPv4 algorithm.
> 
> The IPv6 flow label was intentionally not included in the hash as it appears
> to be unset in the vast majority of IPv6 traffic sampled, and the current
> algorithm not using the flow label already offers a very even distribution.
> 
> Fragmented IPv6 packets are handled the same way as fragmented IPv4 packets,
> ie, they are not balanced based on layer 4 information. Additionally,
> IPv6 packets with intermediate headers are not balanced based on layer
> 4 information. In practice these intermediate headers are not common and
> this should not cause any problems, and the alternative (a packet-parsing
> loop and look-up table) seemed slow and complicated for little gain.
> 
> Tested-by: John Eaglesham <linux@8192.net>
> Signed-off-by: John Eaglesham <linux@8192.net>

Applied, thanks a lot.
