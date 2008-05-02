From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [ANNOUNCE] ixgbe: Data Center Bridging (DCB) support for ixgbe
Date: Fri, 2 May 2008 13:18:33 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC3290501D305@orsmsx414.amr.corp.intel.com>
References: <20080502004254.14392.7599.stgit@localhost.localdomain> <87bq3peyxh.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <jgarzik@pobox.com>, <netdev@vger.kernel.org>
To: "Andi Kleen" <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:4248 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763288AbYEBUSc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 16:18:32 -0400
Content-class: urn:content-classes:message
In-Reply-To: <87bq3peyxh.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Probably the interface shouldn't be driver specific.
> 
> I would suggest you post a higher level description of the 
> goals/implementation etc. of the interface.

Agreed the netlink interface being driver-specific isn't very desirable.
I'm going to look more at the ethtool-netlink interface Jeff mentioned
in the meantime; but here is the basic need for the interface:

DCB allows configuration of both Tx and Rx parameters for bandwidth
control and priority flow control settings.  It also has the ability to
group traffic classes into bandwidth groups, which can then have other
features turned on to control the way bandwidth is arbitrated within the
bandwidth group itself, and across bandwidth groups.  Note that all of
these settings are in hardware, so we need an interface to the driver to
feed these configuration sets into the hardware.  Originally we thought
ethtool, but the number of ioctls we would need to add in order to
support the dataset was pretty huge.  So we chose to try using netlink,
and not pollute ethtool at this point.

We have a set of userspace tools that will be posted to Sourceforge
shortly.  There is a daemon (dcbd) and a command-line tool (dcbtool).
The daemon is the code that implements the netlink interface into the
driver, and feeds the configuration sent from dcbtool or from its local
configuration file.  dcbd also implements the Data Center Bridging
Exchange protocol, which is an LLDP-based protocol that allows DCB
devices to negotiate settings between link partners.  The recently
announced Cisco Nexus switches run a DCB exchange service that
implements the protocol (I don't have the spec link for it, but it's a
joint spec from Intel, Cisco, and IBM).  So our userspace tool
implements the protocol, performs all the negotiation with the link
partners, and sends the configuration changes to the driver via netlink.

I hope that gives a better understanding of how the driver interface
works.  Please feel free to ask additional questions and give more
suggestions/feedback.

Cheers,
-PJ Waskiewicz
