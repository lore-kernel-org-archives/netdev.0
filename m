From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] NET: Multiqueue network device support.
Date: Wed, 6 Jun 2007 15:30:39 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32902FC61BF@orsmsx414.amr.corp.intel.com>
References: <1181168020.4064.46.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: <hadi@cyberus.ca>, "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:51695 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935834AbXFFWal convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 18:30:41 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1181168020.4064.46.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> [Which of course leads to the complexity (and not optimizing 
> for the common - which is single ring NICs)].

The common for 100 Mbit and older 1Gbit is single ring NICs.  Newer
PCI-X and PCIe NICs from 1Gbit to 10Gbit support multiple rings in the
hardware, and it's all headed in that direction, so it's becoming the
common case.

> Infact for the wired case i see little value (there is some) 
> in using multiple rings. In the case of wireless (which is 
> strict prio based) it provides more value.

There is value, hence why NIC manufacturers are building wired parts
that support multiple rings today.  And wireless may not want strict
prio in software, and may just want round-robin from the stack.  Either
way, Yi Zhu has represented the wireless side in this discussion
agreeing with these per-queue control patches.  Is wireless not a common
case to be considered?

> > I would love to see your alternative patches.
> 
> >From the above you can see they are simple.

The description above won't provide what I'm trying to solve and what
wireless has stated they want.

> Iam actually not against the subqueue control - i know Peter 
> needs it for certain hardware; i am just against the mucking 
> around of the common case (single ring NIC) just to get that working. 

Single-ring NICs see no difference here.  Please explain why using my
patches with pfifo_fast, sch_prio, or any other existing qdisc will
change the behavior for single-ring NICs?  If the driver doesn't call
alloc_etherdev_mq() explicity, or use the new sch_rr qdisc, then the Tx
path is identical to the kernel today.  What am I mucking around with?
And these patches are not for specific hardware; rather they're for all
the NICs today that have multiple rings, and want to control them in the
OS instead of the driver, which is most of wireless and a handful of
NICs from Intel and Neterion afaik.

-PJ Waskiewicz
