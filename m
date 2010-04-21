From: David Miller <davem@davemloft.net>
Subject: Re: crash with bridge and inconsistent handling of NETDEV_TX_OK
Date: Tue, 20 Apr 2010 18:14:34 -0700 (PDT)
Message-ID: <20100420.181434.35828504.davem@davemloft.net>
References: <Pine.LNX.4.64.1004202018100.16302@hs20-bc2-1.build.redhat.com>
	<20100420.180253.159346294.davem@davemloft.net>
	<Pine.LNX.4.64.1004202108240.27476@hs20-bc2-1.build.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: mpatocka@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48742
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754493Ab0DUBO3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 21:14:29 -0400
In-Reply-To: <Pine.LNX.4.64.1004202108240.27476@hs20-bc2-1.build.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mikulas Patocka <mpatocka@redhat.com>
Date: Tue, 20 Apr 2010 21:10:04 -0400 (EDT)

> I see, but GRO is turned off on my interfaces, according to ethtool.

GRO is just a flag bit, so it's possible that if your kernel is too
old ethtool will always show that it's off.

If you haven't turned off GRO explicitly, then it's a good bet that
this is why it looks like it's off.  And GRO is on by default.

I still contend, therefore, that it's completely normal to see GSO
packet processing in the TX code path, even with bridging, and
therefore seeing the GSO code path get taken is not indicative of some
bug wrt. ->ndo_start_xmit() return value flag bit handling.
