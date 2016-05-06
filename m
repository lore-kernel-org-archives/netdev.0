From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3 2/2] udp_offload: Set encapsulation before inner
 completes.
Date: Fri, 06 May 2016 15:34:12 -0400 (EDT)
Message-ID: <20160506.153412.1756777490005831525.davem@davemloft.net>
References: <1462317021-7236-1-git-send-email-jarno@ovn.org>
	<1462317021-7236-2-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.duyck@gmail.com,
	tom@herbertland.com
To: jarno@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48674 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758809AbcEFTeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 15:34:16 -0400
In-Reply-To: <1462317021-7236-2-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarno Rajahalme <jarno@ovn.org>
Date: Tue,  3 May 2016 16:10:21 -0700

> UDP tunnel segmentation code relies on the inner offsets being set for
> an UDP tunnel GSO packet, but the inner *_complete() functions will
> set the inner offsets only if 'encapsulation' is set before calling
> them.  Currently, udp_gro_complete() sets 'encapsulation' only after
> the inner *_complete() functions are done.  This causes the inner
> offsets having invalid values after udp_gro_complete() returns, which
> in turn will make it impossible to properly segment the packet in case
> it needs to be forwarded, which would be visible to the user either as
> invalid packets being sent or as packet loss.
> 
> This patch fixes this by setting skb's 'encapsulation' in
> udp_gro_complete() before calling into the inner complete functions,
> and by making each possible UDP tunnel gro_complete() callback set the
> inner_mac_header to the beginning of the tunnel payload.
> 
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> ---
> v3: Added setting inner_mac_header from all possible callbacks to cover
>     cases where there is no inner mac header.

Alex and Tom, can you please review this new version since you guys had
so much feedback for v2?

THanks.
