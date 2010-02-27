From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] skbuff: align sk_buff::cb to 64 bit and close some
 potential holes
Date: Sat, 27 Feb 2010 03:17:27 -0800 (PST)
Message-ID: <20100227.031727.143841315.davem@davemloft.net>
References: <4B671F79.8090808@openwrt.org>
	<20100212.121306.225788982.davem@davemloft.net>
	<4B844C8F.2060908@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ddaney@caviumnetworks.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, buytenh@wantstofly.org
To: nbd@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40406
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965502Ab0B0LRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 06:17:09 -0500
In-Reply-To: <4B844C8F.2060908@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Fietkau <nbd@openwrt.org>
Date: Tue, 23 Feb 2010 22:45:51 +0100

> The alignment requirement for 64-bit load/store instructions on ARM is
> implementation defined. Some CPUs (such as Marvell Feroceon) do not
> generate an exception, if such an instruction is executed with an
> address that is not 64 bit aligned. In such a case, the Feroceon
> corrupts adjacent memory, which showed up in my tests as a crash in the
> rx path of ath9k that only occured with CONFIG_XFRM set.
> 
> This crash happened, because the first field of the mac80211 rx status
> info in the cb is an u64, and changing it corrupted the skb->sp field.
> 
> This patch also closes some potential pre-existing holes in the sk_buff
> struct surrounding the cb[] area.
> 
> Signed-off-by: Felix Fietkau <nbd@openwrt.org>
> Cc: stable@kernel.org

Applied, thanks for following up on this Felix.
