From: David Miller <davem@davemloft.net>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Fri, 28 Aug 2009 12:26:58 -0700 (PDT)
Message-ID: <20090828.122658.188210079.davem@davemloft.net>
References: <alpine.DEB.1.10.0908280948320.3747@gentwo.org>
	<4A97F2B4.7030900@gmail.com>
	<alpine.DEB.1.10.0908281211150.7317@gentwo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, sri@us.ibm.com, dlstevens@us.ibm.com,
	netdev@vger.kernel.org, niv@linux.vnet.ibm.com
To: cl@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49187
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752469AbZH1T0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 15:26:44 -0400
In-Reply-To: <alpine.DEB.1.10.0908281211150.7317@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <cl@linux-foundation.org>
Date: Fri, 28 Aug 2009 12:15:39 -0400 (EDT)

> Because you need drop statistics on a device to figure out when you may
> want to increase the TX buffers for a device. If a packet was dropped
> because of a lack of TX buffers then we need to know.

Christoph, the qdisc layer is there and is where the drops occur, and
you therefore have to be aware of it.

I'm not accepting changes like the patch you propose here, it's not
the correct thing to do.

The device never saw the packet, it never dropped it.

The qdisc saw it, the qdisc dropped it, and therefore that's where we
account for it.
