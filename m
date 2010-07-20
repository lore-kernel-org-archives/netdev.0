From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/5] ixgbe: drop support for UDP in RSS
 hash generation
Date: Mon, 19 Jul 2010 23:44:54 -0700 (PDT)
Message-ID: <20100719.234454.123445936.davem@davemloft.net>
References: <20100719235831.14112.14175.stgit@localhost.localdomain>
	<20100719235925.14112.65890.stgit@localhost.localdomain>
	<1279607980.2458.82.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com, alexander.h.duyck@intel.com,
	donald.c.skidmore@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57710
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754398Ab0GTGoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 02:44:38 -0400
In-Reply-To: <1279607980.2458.82.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 20 Jul 2010 08:39:40 +0200

> This would be a serious regression.

The regression is in the hardware Eric.

> Many UDP applications try hard to not use fragments. 
> 
> They are going to pay the price because some application :
> - Use big segments, fragmented.
> - Is subject to OOO artifacts.

None of this matters.  If the hardware can't flow seperate properly
it's tough cookies.

We never may reorder packets in our stack by our own doing.  The
only safe default is to turn UDP flow seperation off on chips
like ixgbe.

If you want an ethtool knob to turn it back on for your machines,
fine.  But never can it be enabled by default.
