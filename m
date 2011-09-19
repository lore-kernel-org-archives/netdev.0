From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 11/13] igb: Make Tx budget for NAPI user adjustable
Date: Mon, 19 Sep 2011 17:00:33 -0400 (EDT)
Message-ID: <20110919.170033.344802441047363137.davem@davemloft.net>
References: <4E776441.9090602@intel.com>
	<1316448352.2764.27.camel@bwh-desktop>
	<4E776E92.6090303@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44879 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755608Ab1ISVAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 17:00:42 -0400
In-Reply-To: <4E776E92.6090303@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Mon, 19 Sep 2011 09:32:18 -0700

> The fact is ixgbe has been using this parameter this way for over 2
> years now and the main goal of this patch was just to synchronize how
> things work on igb and ixgbe.
> 
> Our hardware doesn't have a mechanism for firing an interrupt after X
> number of frames so instead we simply have modified things so that we
> will only process X number of frames and then fire another
> interrupt/poll if needed.  As such we aren't that far out of
> compliance with the meaning of how this parameter is supposed to be
> used.

All I can say is this was a huge mistake you therefore need to revert
the IXGBE change, these ethtool settings are not for changing NAPI or
software interrupt behavior.

And if you guys plan to be difficult on this and refuse to remove the
IXGBE bits, I'm letting you guys know ahead of time that I'll do it
for you.

If the hardware can't support this facility, neither should these
ethtool hooks, because the whole point is to avoid hardware interrupts
from firing using these parameters.

Propose new mechanisms to control NAPI behavior if you want.
