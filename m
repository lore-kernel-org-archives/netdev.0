From: David Miller <davem@davemloft.net>
Subject: Re: sending VLAN packets via packet_mmap
Date: Wed, 06 Oct 2010 23:53:43 -0700 (PDT)
Message-ID: <20101006.235343.98903661.davem@davemloft.net>
References: <20100930192414.GD26509@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johann.baudy@gnu-log.net,
	eric.dumazet@gmail.com
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50571
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751816Ab0JGGxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 02:53:22 -0400
In-Reply-To: <20100930192414.GD26509@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Thu, 30 Sep 2010 21:24:14 +0200

> The actual problem in tpacket_snd() is this:
> 
> | reserve = dev->hard_header_len;
> | [...]
> | if (size_max > dev->mtu + reserve)
> | 	size_max = dev->mtu + reserve;
> 
> I guess the check is there to avoid skb overflows on malicious data
> input. Is this correct? Are there other reasons for it's existence?

We can add a special allowance of 4 extra bytes in this size check
_iff_ the device is ethernet and the NETIF_F_VLAN_CHALLENGED netdev
feature bit is not set.

