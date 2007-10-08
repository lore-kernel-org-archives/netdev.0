From: jamal <hadi@cyberus.ca>
Subject: Re: parallel networking
Date: Mon, 08 Oct 2007 18:30:18 -0400
Message-ID: <1191882618.4373.99.camel@localhost>
References: <20071007.215124.85709188.davem@davemloft.net>
	 <1191850490.4352.41.camel@localhost> <470A3D24.3050803@garzik.org>
	 <20071008.141154.107706003.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, peter.p.waskiewicz.jr@intel.com,
	krkumar2@in.ibm.com, johnpol@2ka.mipt.ru,
	herbert@gondor.apana.org.au, kaber@trash.net,
	shemminger@linux-foundation.org, jagana@us.ibm.com,
	Robert.Olsson@data.slu.se, rick.jones2@hp.com, xma@us.ibm.com,
	gaagaan@gmail.com, netdev@vger.kernel.org, rdreier@cisco.com,
	mingo@elte.hu, mchan@broadcom.com, general@lists.openfabrics.org,
	kumarkr@linux.ibm.com, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.235]:65236 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875AbXJHWaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 18:30:24 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1456395wxd
        for <netdev@vger.kernel.org>; Mon, 08 Oct 2007 15:30:22 -0700 (PDT)
In-Reply-To: <20071008.141154.107706003.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-08-10 at 14:11 -0700, David Miller wrote:

> The problem is that the packet schedulers want global guarantees
> on packet ordering, not flow centric ones.
> 
> That is the issue Jamal is concerned about.

indeed, thank you for giving it better wording. 

> The more I think about it, the more inevitable it seems that we really
> might need multiple qdiscs, one for each TX queue, to pull this full
> parallelization off.
> 
> But the semantics of that don't smell so nice either.  If the user
> attaches a new qdisc to "ethN", does it go to all the TX queues, or
> what?
> 
> All of the traffic shaping technology deals with the device as a unary
> object.  It doesn't fit to multi-queue at all.

If you let only one CPU at a time access the "xmit path" you solve all
the reordering. If you want to be more fine grained you make the
serialization point as low as possible in the stack - perhaps in the
driver.
But I think even what we have today with only one cpu entering the
dequeue/scheduler region, _for starters_, is not bad actually ;->  What
i am finding (and i can tell you i have been trying hard;->) is that a
sufficiently fast cpu doesnt sit in the dequeue area for "too long" (and
batching reduces the time spent further). Very quickly there are no more
packets for it to dequeue from the qdisc or the driver is stoped and it
has to get out of there. If you dont have any interupt tied to a
specific cpu then you can have many cpus enter and leave that region all
the time. 

cheers,
jamal

