From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: gianfar: multiqueue, vlan pbits -> qos?
Date: Mon, 31 Mar 2008 11:33:07 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32904CA4A45@orsmsx414.amr.corp.intel.com>
References: <47EE9CCD.8080304@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <afleming@freescale.com>
To: "Randy Macleod" <macleodr@nortel.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:47680 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753870AbYCaSep convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 14:34:45 -0400
Content-class: urn:content-classes:message
In-Reply-To: <47EE9CCD.8080304@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Has anyone done this already?

Take a look at the ixgbe driver (multiple Tx queues, multiple Rx with
RSS queues) in the net-2.6.26 tree.

> I'm also poking at the multi-queue work that has been done and
wondering how that might fit into a solution.
> I haven't read the e1000 multiqueue driver yet...

E1000 was my original target for multiqueue, but ixgbe made more sense
while the e1000/e1000e driver split was happening.  Basically the way
the multiqueue kernel side works is to use a multiqueue-aware qdisc
(prio or round-robin).  When you filter (via tc, iptables and tc), the
packet's skb->queue_mapping field is populated.  Then use that field in
your driver to select which Tx queue to use.

As for Rx, you'll need some sort of hardware support to truly filter off
the wire without heavy driver lifting.  Look at e1000, e1000e, igb, or
ixgbe, for the RSS setup for Rx.  I'm not sure what your hardware
supports, but this might be there already.

Hope this helps.  Feel free to ping me about the Tx multiqueue stuff if
you have additional questions,

Cheers,
-PJ Waskiewicz
