From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Tue, 15 May 2007 14:32:07 -0700 (PDT)
Message-ID: <20070515.143207.80029051.davem@davemloft.net>
References: <adahcqdpz1p.fsf@cisco.com>
	<OFF5654BB8.74EC8DCB-ON872572DC.00752079-882572DC.00756B23@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, ak@suse.de, krkumar2@in.ibm.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: xma@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58452
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754401AbXEOVcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 17:32:01 -0400
In-Reply-To: <OFF5654BB8.74EC8DCB-ON872572DC.00752079-882572DC.00756B23@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shirley Ma <xma@us.ibm.com>
Date: Tue, 15 May 2007 14:22:57 -0700

>       I just wonder without TSO support in HW, how much benefit we
> can get by pushing GSO from interface layer to device layer besides
> we can do multiple packets in IPoIB.

I bet the gain is non-trivial.

I'd say about half of the gain from TSO comes from only calling down
into the driver from TCP one time as opposed to N times.  That's
the majority of the "CPU work" involved in TCP sending.

The rest of the gain comes from only transmitting the packet headers
once rather than N times, which conserves I/O bus bandwidth.

GSO will not help the case of lots of UDP applications sending
small packets, or something like that.  An efficient qdisc-->driver
transfer during netif_wake_queue() could help solve some of that,
as is being discussed here.
