From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/3] ixgbe: Add Data Center Bridging netlink listener
 for DCB runtime changes.
Date: Fri, 16 May 2008 16:20:22 -0700
Message-ID: <20080516162022.41ee0b07@extreme>
References: <20080502004254.14392.7599.stgit@localhost.localdomain>
	<20080502004300.14392.87943.stgit@localhost.localdomain>
	<481AF501.3030507@pobox.com>
	<D5C1322C3E673F459512FB59E0DDC3290509D540@orsmsx414.amr.corp.intel.com>
	<48221B79.2010808@pobox.com>
	<D5C1322C3E673F459512FB59E0DDC32905168831@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jgarzik@pobox.com>,
	"David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:56534 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754703AbYEPXU2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2008 19:20:28 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32905168831@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 May 2008 15:45:11 -0700
"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com> wrote:

> > But like everything else in life, one must weight various 
> > costs.  Maybe it is complex enough to warrant a new tool.  We 
> > don't know until there's a design doc or review of the 
> > generic interface that will be used for DCB.
> 
> 100% agree.  I have a design document added to the bottom of this email
> in plain text for the in-kernel design.  I can send a PDF or OpenOffice
> doc if desired.  Please review it, see if that's something worth
> supporting and developing, and send feedback.  If things look ok, I'll
> write the in-kernel layer and send those patches asap, along with a
> modified ixgbe to use the new interface.
> 
> Thanks Jeff,
> 
> -PJ Waskiewicz
> <peter.p.waskiewicz.jr@intel.com>
> 
> ------------------------------------------------------
> 
> Linux Kernel Interface Design for Data Center Bridging
> Peter P. Waskiewicz Jr, Intel Corp.
> 5/16/2008
> 
> Overview:
> 	Data Center Bridging is a new layer 2 networking technology
> targeted for data centers looking to converge certain network flows.
> The technology uses 802.1p priority tagging from 802.1q, and then adds
> the new 802.1Qaz Priority Grouping and 802.1Qbb Priority Flow Control
> technologies.  The purpose is to provide per-priority flow control to
> individual network flows without impacting other flows.  It also
> provides the mechanism to enforce bandwidth allocation per flow.
> 	A Wikipedia article describing the network-wide model this fits
> into can be found here:
> http://en.wikipedia.org/wiki/Data_Center_Ethernet.
> 


I wonder if doing this generically with existing bridge code would
be a better approach. It seems like the TOE problem all over again,
only this time it is Traffic Control offload. Sorry, just because
you can do it in hardware doesn't mean it is a good thing.

