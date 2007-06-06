From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Wed, 06 Jun 2007 15:40:41 -0700 (PDT)
Message-ID: <20070606.154041.08321169.davem@davemloft.net>
References: <1181168020.4064.46.camel@localhost>
	<D5C1322C3E673F459512FB59E0DDC32902FC61BF@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, kaber@trash.net, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54475
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764852AbXFFWk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 18:40:26 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32902FC61BF@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Wed, 6 Jun 2007 15:30:39 -0700

> > [Which of course leads to the complexity (and not optimizing 
> > for the common - which is single ring NICs)].
> 
> The common for 100 Mbit and older 1Gbit is single ring NICs.  Newer
> PCI-X and PCIe NICs from 1Gbit to 10Gbit support multiple rings in the
> hardware, and it's all headed in that direction, so it's becoming the
> common case.

I totally agree.  No modern commodity 1gb and faster card is going
to be without many queues on both TX and RX.

> > Iam actually not against the subqueue control - i know Peter 
> > needs it for certain hardware; i am just against the mucking 
> > around of the common case (single ring NIC) just to get that working. 
> 
> Single-ring NICs see no difference here.  Please explain why using my
> patches with pfifo_fast, sch_prio, or any other existing qdisc will
> change the behavior for single-ring NICs?

I agree with the implication here, there is no penalty for existing
devices.

There are two core issues in my mind:

1) multi-queue on both RX and TX is going to be very pervasive very
   soon, everyone is putting this into silicon.

   The parallelization gain potential is enormous, and we have to
   design for this.

2) Queues are meant to be filled as much as possible, you can't do
   that by having only one qdisc attached to the device indicating
   unary full status, you simply can't.
