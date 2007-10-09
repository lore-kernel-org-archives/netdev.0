From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Tue, 9 Oct 2007 20:30:27 +0200
Message-ID: <20071009183027.GA552@one.firstfloor.org>
References: <D5C1322C3E673F459512FB59E0DDC32903BC14AC@orsmsx414.amr.corp.intel.com> <1191886845.4373.138.camel@localhost> <470AD5D7.1070000@garzik.org> <20071008.184126.124062865.davem@davemloft.net> <p73k5pw44ew.fsf@bingen.suse.de> <20071009112225.5f9756e7@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, jeff@garzik.org,
	johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	netdev@vger.kernel.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	mcarlson@broadcom.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	randy.dunlap@oracle.com, sri@us.ibm.com, kaber@trash.net
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:39166 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371AbXJISaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 14:30:30 -0400
Content-Disposition: inline
In-Reply-To: <20071009112225.5f9756e7@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I wonder about the whole idea of queueing in general at such high speeds.
> Given the normal bi-modal distribution of packets, and the predominance
> of 1500 byte MTU; does it make sense to even have any queueing in software
> at all?

Yes that is my point -- it should just pass it through directly
and the driver can then put it into the different per CPU (or per
whatever) queues managed by the hardware.

The only thing the qdisc needs to do is to set some bit that says
"it is ok to put this into difference queues; don't need strict ordering" 

Otherwise if the drivers did that unconditionally they might cause
problems with other qdiscs.

This would also require that the driver exports some hint 
to the upper layer on how large its internal queues are. A device
with a short queue would still require pfifo_fast. Long queue
devices could just pass through. That again could be a single flag.

-Andi
