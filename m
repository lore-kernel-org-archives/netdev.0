From: David Miller <davem@davemloft.net>
Subject: Re: IPoIB: Fix multicast packet drops before join is complete
Date: Tue, 09 Jun 2009 21:57:19 -0700 (PDT)
Message-ID: <20090609.215719.214969588.davem@davemloft.net>
References: <adaocsx3zaa.fsf@cisco.com>
	<20090609.174504.114047526.davem@davemloft.net>
	<ada1vps4u9e.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cl@linux-foundation.org, netdev@vger.kernel.org,
	yosefe@Voltaire.COM
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47449
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750783AbZFJE5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 00:57:17 -0400
In-Reply-To: <ada1vps4u9e.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <rdreier@cisco.com>
Date: Tue, 09 Jun 2009 20:55:57 -0700

> Hmm... how do I do that?  The interface gets an skb that it sees should
> be sent to a multicast group that it is not a member of yet, and so it
> fires off a request to join that group (as a send-only member).  How
> does a netdev block the process that queued up a given skb to send?
> Couldn't the packet have come through a local software bridge or
> something like that, so the original process is long since lost to the
> network stack?

If a facility doesn't exist yet, we're going to have to create
one.  It would need to do a downcall to the device when the
user joins a multicast group on a socket, and then the device
can do whatever magic is necessary to speak multicast immediately
and sleep until it really is available for immediate use.

