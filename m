From: David Miller <davem@davemloft.net>
Subject: Re: [NET 00/02]: MACVLAN driver
Date: Tue, 19 Jun 2007 15:48:40 -0700 (PDT)
Message-ID: <20070619.154840.55744015.davem@davemloft.net>
References: <20070619130825.26769.23059.sendpatchset@localhost.localdomain>
	<20070619090027.3312f2cf@localhost.localdomain>
	<4678472D.5050907@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58741
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759016AbXFSWsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 18:48:21 -0400
In-Reply-To: <4678472D.5050907@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 19 Jun 2007 23:14:21 +0200

> Stephen Hemminger wrote:
> > Looks good. I have some changes to allow devices with multiple MAC addresses
> > (never finished).  This device could use that.
> 
> 
> How would the driver do that? I was thinking about using dev_add_mc,
> but wasn't sure if that would work with all drivers for non-multicast
> addresses.

This is actually a real issue for virtualization, and many
if not all current generation ethernet chips support
programming several unicast ethernet addresses in the MAC.

Networking switches in domain0 on virtualization hosts use
this feature to support seperate MACs per guest node,
and if the chip doesn't support this the chip is put into
promiscuous mode.

We don't have any clean interfaces by which to do this MAC
programming, and we do need something for it soon.
