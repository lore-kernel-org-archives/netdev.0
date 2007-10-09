From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: 09 Oct 2007 18:51:51 +0200
Message-ID: <p73k5pw44ew.fsf@bingen.suse.de>
References: <D5C1322C3E673F459512FB59E0DDC32903BC14AC@orsmsx414.amr.corp.intel.com>
	<1191886845.4373.138.camel@localhost> <470AD5D7.1070000@garzik.org>
	<20071008.184126.124062865.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	netdev@vger.kernel.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	mcarlson@broadcom.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	randy.dunlap@oracle.com, sri@us.ibm.com,
	shemminger@linux-foundation.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:57168 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751495AbXJIQv5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2007 12:51:57 -0400
In-Reply-To: <20071008.184126.124062865.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:
> 
> 2) Switch the default qdisc away from pfifo_fast to a new DRR fifo
>    with load balancing using the code in #1.  I think this is kind
>    of in the territory of what Peter said he is working on.

Hopefully that new qdisc will just use the TX rings of the hardware
directly. They are typically large enough these days. That might avoid
some locking in this critical path.

>    I know this is controversial, but realistically I doubt users
>    benefit at all from the prioritization that pfifo provides.

I agree. For most interfaces the priority is probably dubious.
Even for DSL the prioritization will be likely usually done in a router
these days.

Also for the fast interfaces where we do TSO priority doesn't work
very well anyways -- with large packets there is not too much 
to prioritize.

> 3) Work on discovering a way to make the locking on transmit as
>    localized to the current thread of execution as possible.  Things
>    like RCU and statistic replication, techniques we use widely
>    elsewhere in the stack, begin to come to mind.

If the data is just passed on to the hardware queue, why is any 
locking needed at all? (except for the driver locking of course)

-Andi
