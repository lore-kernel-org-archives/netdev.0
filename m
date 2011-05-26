From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af-packet: Add flag to distinguish VID 0 from no-vlan.
Date: Thu, 26 May 2011 16:19:30 -0400 (EDT)
Message-ID: <20110526.161930.2032005598678118168.davem@davemloft.net>
References: <1306366595-731-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59601 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086Ab1EZUTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 16:19:33 -0400
In-Reply-To: <1306366595-731-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: greearb@candelatech.com
Date: Wed, 25 May 2011 16:36:35 -0700

> From: Ben Greear <greearb@candelatech.com>
> 
> Currently, user-space cannot determine if a 0 tcp_vlan_tci
> means there is no VLAN tag or the VLAN ID was zero.
> 
> Add flag to make this explicit.  User-space can check for
> TP_STATUS_VLAN_VALID || tp_vlan_tci > 0, which will be backwards
> compatible. Older could would have just checked for tp_vlan_tci,
> so it will work no worse than before.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>

Please do this in tpacket_rcv() too, otherwise the feature
bit won't be available to mmap() users of AF_PACKET.

Thanks.
