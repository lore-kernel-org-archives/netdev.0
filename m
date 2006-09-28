From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] loopback: minor statistics optimization
Date: Wed, 27 Sep 2006 20:04:59 -0700 (PDT)
Message-ID: <20060927.200459.13769170.davem@davemloft.net>
References: <20060908111613.12c1f9b8@localhost.localdomain>
	<20060908112056.7ef03bac@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:35240
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965236AbWI1DFA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 23:05:00 -0400
To: shemminger@osdl.org
In-Reply-To: <20060908112056.7ef03bac@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Fri, 8 Sep 2006 11:20:56 -0700

> Minor loopback enhancements for 2.6.19
> 
> The loopback device status structure is a singleton and doesn't
> need to be allocated. Add ethtool_ops hooks to show checksum always on,
> and make ethtool_ops const.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

The ethtool bits are OK, but putting the loopback stats into
the image adds nearly 200 bytes of .data section space on
64-bit.

I don't really think it's that big of a deal to avoid the
kmalloc() call.
