From: David Miller <davem@davemloft.net>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Fri, 28 Aug 2009 12:24:59 -0700 (PDT)
Message-ID: <20090828.122459.245170385.davem@davemloft.net>
References: <alpine.DEB.1.10.0908271139450.14277@gentwo.org>
	<alpine.DEB.1.10.0908271621260.28029@gentwo.org>
	<alpine.DEB.1.10.0908280948320.3747@gentwo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, dlstevens@us.ibm.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, niv@linux.vnet.ibm.com
To: cl@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43871
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752645AbZH1TYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 15:24:45 -0400
In-Reply-To: <alpine.DEB.1.10.0908280948320.3747@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <cl@linux-foundation.org>
Date: Fri, 28 Aug 2009 09:53:40 -0400 (EDT)

> Seems though that the qdisc drop count does not flow into the tx_dropped
> counter for the interface.

And it should not.

The qdisc drops the packet due to flow control, not the hardware
device.

Device drops are for things like transmission errors on the wire.

If you start incrementing tx_dropped here, people won't be able
to tell they have a deteriorating cable or bad switch or similar.
