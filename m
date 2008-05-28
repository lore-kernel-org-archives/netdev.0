From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 1/3] [NET-NEXT]: Add DCB netlink interface definition
Date: Wed, 28 May 2008 09:03:57 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32905281CD4@orsmsx414.amr.corp.intel.com>
References: <20080527141339.12851.98781.stgit@localhost.localdomain> <20080527141346.12851.2280.stgit@localhost.localdomain> <20080528094140.GD20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <jeff@garzik.org>, <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:15465 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751303AbYE1QEA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2008 12:04:00 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080528094140.GD20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Is there a specific reason why you used a separate generic 
> netlink interface instead of embedding this into the regular 
> link message via either IFLA_DCB or by using the info API?

There are four reasons we decided to use a separate interface:

1. The netlink messages are generated via userspace when the connection
is setup, plus they're generated from LLDP frames coming in off the
wire.  Those LLDP frames implement the DCBX protocol (Data Center
Bridging Exchange), which is the negotiation protocol between a DCB
device and its link partner.  In most cases, it's a DCB-compliant
switch, like a Cisco Nexus 5000.  So the messages can come out of band
depending on how the network gets configured, and if any events occur
causing the bandwidth credits or priority mappings to change (think
automated backups at night, wanting more bandwidth than during the day).

2. The DCBX protocol is being extended to contain more information, and
second generation DCB devices have more configuration data for the
network.  So we wanted an interface that could be extended on its own to
support the new DCB protocols as they're ratified and implemented in new
equipment, without impacting existing infrastructure.

3. We wanted to use generic netlink, since that seems to be a more
preferred method of netlink communication vs. rtnetlink.  And I don't
know anything about the info API, so I can't comment on why we didn't
look at that for implementation.  Can you suggest something for me to
look at for the info API so I can see what that's all about?

4. We also developed the userspace utilities for the Linux OSVs, which
should be having a pre-release "release" on Sourceforge in the next week
or so, to support the DCBX protocol.  They're implemented using the
generic netlink interface, so obviously if we can keep it that way, it'd
be preferred.  :-)

Thanks Thomas.  Other than that, is there anything in the netlink
interface that you would suggest to change?

Cheers,
-PJ Waskiewicz
