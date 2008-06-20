From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3]: tg3: Manage TX backlog in-driver.
Date: Fri, 20 Jun 2008 12:04:22 -0700 (PDT)
Message-ID: <20080620.120422.193703152.davem@davemloft.net>
References: <20080619.041024.116139711.davem@davemloft.net>
	<OFD7CC7687.E0D15399-ON6525746E.0038A920-6525746E.003B6162@in.ibm.com>
	<20080620145233.3e11b6fe.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, mchan@broadcom.com, netdev@vger.kernel.org,
	vinay@linux.vnet.ibm.com
To: billfink@mindspring.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34453
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752054AbYFTTEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 15:04:23 -0400
In-Reply-To: <20080620145233.3e11b6fe.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bill Fink <billfink@mindspring.com>
Date: Fri, 20 Jun 2008 14:52:33 -0400

> I have a general question about this new tx queueing model, which
> I haven't seen discussed to this point.
> 
> Although hopefully not frequent events, if the tx queue is kept in
> the driver rather than the network midlayer, what are the ramifications
> of a routing change which requires changing the output to a new interface,
> considering for example that on our 10-GigE interfaces we typically set
> txqueuelen to 10000.

All of the packets would have been in the existing mid-layer generic
backlog anyways, way past the routing decisions.  Nothing about
behavior in this area would be changing.

> Similarly, what are the ramifications of such a change to the bonding
> driver (either in a load balancing or active/backup scenario) when one
> of the interfaces fails (again hopefully a rare event).

Since the bonding driver acts like a pass-thru, and because of the
above, I expect no real ramifications in this area as well.
