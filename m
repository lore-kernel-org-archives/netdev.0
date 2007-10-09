From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Tue, 09 Oct 2007 04:02:55 -0700 (PDT)
Message-ID: <20071009.040255.71088090.davem@davemloft.net>
References: <D5C1322C3E673F459512FB59E0DDC32903BC14AC@orsmsx414.amr.corp.intel.com>
	<OF8571378C.BCC92C60-ON6525736F.003A8E75-6525736F.003C488C@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, gaagaan@gmail.com,
	general@lists.openfabrics.org, hadi@cyberus.ca,
	herbert@gondor.apana.org.au, jagana@us.ibm.com, jeff@garzik.org,
	johnpol@2ka.mipt.ru, kaber@trash.net, mcarlson@broadcom.com,
	mchan@broadcom.com, netdev@vger.kernel.org,
	randy.dunlap@oracle.com, rdreier@cisco.com, rick.jones2@hp.com,
	Robert.Olsson@data.slu.se, shemminger@linux-foundation.org,
	sri@us.ibm.com, tgraf@suug.ch, xma@us.ibm.com
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55091
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752292AbXJILC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 07:02:56 -0400
In-Reply-To: <OF8571378C.BCC92C60-ON6525736F.003A8E75-6525736F.003C488C@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krishna Kumar2 <krkumar2@in.ibm.com>
Date: Tue, 9 Oct 2007 16:28:27 +0530

> Isn't it enough that the multiqueue+batching drivers handle skbs
> belonging to different queue's themselves, instead of qdisc having
> to figure that out? This will reduce costs for most skbs that are
> neither batched nor sent to multiqueue devices.
> 
> Eg, driver can keep processing skbs and put to the correct tx_queue
> as long as mapping remains the same. If the mapping changes, it posts
> earlier skbs (with the correct lock) and then iterates for the other
> skbs that have the next different mapping, and so on.

The complexity in most of these suggestions is beginning to drive me a
bit crazy :-)

This should be the simplest thing in the world, when TX queue has
space, give it packets.  Period.

When I hear suggestions like "have the driver pick the queue in
->hard_start_xmit() and return some special status if the queue
becomes different".....  you know, I really begin to wonder :-)

If we have to go back, get into the queueing layer locks, have these
special cases, and whatnot, what's the point?

This code should eventually be able to run lockless all the way to the
TX queue handling code of the driver.  The queueing code should know
what TX queue the packet will be bound for, and always precisely
invoke the driver in a state where the driver can accept the packet.

Ignore LLTX, it sucks, it was a big mistake, and we will get rid of
it.
