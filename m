From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 01/15] nfp: correct RX buffer length
 calculation
Date: Tue, 05 Apr 2016 11:39:17 -0400 (EDT)
Message-ID: <20160405.113917.846241936652070162.davem@davemloft.net>
References: <1459544811-24879-1-git-send-email-jakub.kicinski@netronome.com>
	<1459544811-24879-2-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59026 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932823AbcDEPj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 11:39:28 -0400
In-Reply-To: <1459544811-24879-2-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Fri,  1 Apr 2016 22:06:37 +0100

> When calculating the RX buffer length we need to account for
> up to 2 VLAN tags and up to 8 MPLS labels.  Rounding up to 1k
> is an relic of a distant past and can be removed.  While at
> it also remove trivial print statement.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

I disagree with the MPLS aspect of this change.

VLAN is special, in that when the hardware supports VLAN properly, the
VLAN header doesn't eat into the MTU and is sort of "transparent".

But MPLS doesn't work that way.

MPLS is in the main frame and takes up MTU space.

Therefore I see no reason to increase the buffer length by 8 * MPLS
which is just a rediculous amount of wasted space.

I'm not applying this without at least some more explanations about
why exactly you need to account for these values in the commit message.
