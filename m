From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/3] [NET-NEXT]: Add DCB netlink interface definition
Date: Thu, 29 May 2008 00:37:28 +0200
Message-ID: <20080528223728.GF20815@postel.suug.ch>
References: <20080527141339.12851.98781.stgit@localhost.localdomain> <20080527141346.12851.2280.stgit@localhost.localdomain> <20080528094140.GD20815@postel.suug.ch> <D5C1322C3E673F459512FB59E0DDC32905281CD4@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, davem@davemloft.net, netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:48413 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753007AbYE1WhI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 May 2008 18:37:08 -0400
Content-Disposition: inline
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32905281CD4@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Waskiewicz Jr, Peter P <peter.p.waskiewicz.jr@intel.com> 2008-05-28 09:03
> 1. The netlink messages are generated via userspace when the connection
> is setup, plus they're generated from LLDP frames coming in off the
> wire.  Those LLDP frames implement the DCBX protocol (Data Center
> Bridging Exchange), which is the negotiation protocol between a DCB
> device and its link partner.  In most cases, it's a DCB-compliant
> switch, like a Cisco Nexus 5000.  So the messages can come out of band
> depending on how the network gets configured, and if any events occur
> causing the bandwidth credits or priority mappings to change (think
> automated backups at night, wanting more bandwidth than during the day).

There isn't much difference really, instead of using the separate
interface you could simply add a new link attribute IFLA_DCB and issue
a RTM_SETLINK/RTM_GETLINK and send the same information in the same
format. However, I agree with you that a separate interface is better
in this case as dcb requests are not directly connected to other link
changes at all and the dcb message structure is pretty complex.

> 3. We wanted to use generic netlink, since that seems to be a more
> preferred method of netlink communication vs. rtnetlink.  And I don't
> know anything about the info API, so I can't comment on why we didn't
> look at that for implementation.  Can you suggest something for me to
> look at for the info API so I can see what that's all about?

A prominent user is the VLAN code in net/8021q/vlan_netlink.c

> Thanks Thomas.  Other than that, is there anything in the netlink
> interface that you would suggest to change?

Looks good from here, I didn't read it all line by line though.
