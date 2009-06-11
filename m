From: David Miller <davem@davemloft.net>
Subject: Re: IPoIB: Fix multicast packet drops before join is complete
Date: Thu, 11 Jun 2009 16:58:56 -0700 (PDT)
Message-ID: <20090611.165856.108387598.davem@davemloft.net>
References: <ada1vps4u9e.fsf@cisco.com>
	<20090609.215719.214969588.davem@davemloft.net>
	<alpine.DEB.1.10.0906111107390.29827@gentwo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, netdev@vger.kernel.org, yosefe@Voltaire.COM
To: cl@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53170
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755266AbZFKX6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 19:58:54 -0400
In-Reply-To: <alpine.DEB.1.10.0906111107390.29827@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <cl@linux-foundation.org>
Date: Thu, 11 Jun 2009 11:07:52 -0400 (EDT)

> On Tue, 9 Jun 2009, David Miller wrote:
> 
>> From: Roland Dreier <rdreier@cisco.com>
>> Date: Tue, 09 Jun 2009 20:55:57 -0700
>>
>> > Hmm... how do I do that?  The interface gets an skb that it sees should
>> > be sent to a multicast group that it is not a member of yet, and so it
>> > fires off a request to join that group (as a send-only member).  How
>> > does a netdev block the process that queued up a given skb to send?
>> > Couldn't the packet have come through a local software bridge or
>> > something like that, so the original process is long since lost to the
>> > network stack?
>>
>> If a facility doesn't exist yet, we're going to have to create
>> one.  It would need to do a downcall to the device when the
>> user joins a multicast group on a socket, and then the device
>> can do whatever magic is necessary to speak multicast immediately
>> and sleep until it really is available for immediate use.
> 
> Umm?? My patch does that....

No it does not.  It eliminates a limit on the generic intermediate
queue.  It did no blocking, no sleeping, or the process when it
joined the group.

I was suggesting to block the process, at socket context time, when it
joins a multicast group.  That way it wouldn't be able to do any sends
until IPoIB could resolve the multicast join.
