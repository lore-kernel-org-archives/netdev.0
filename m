From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 1/3] ixgbe: Add Data Center Bridging netlink listener for DCB runtime changes.
Date: Sat, 17 May 2008 02:14:30 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329051ABCE1@orsmsx414.amr.corp.intel.com>
References: <20080502004254.14392.7599.stgit@localhost.localdomain><20080502004300.14392.87943.stgit@localhost.localdomain><481AF501.3030507@pobox.com><D5C1322C3E673F459512FB59E0DDC3290509D540@orsmsx414.amr.corp.intel.com><48221B79.2010808@pobox.com><D5C1322C3E673F459512FB59E0DDC32905168831@orsmsx414.amr.corp.intel.com> <20080516162022.41ee0b07@extreme>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Jeff Garzik" <jgarzik@pobox.com>,
	"David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:2385 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752300AbYEQJOb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 May 2008 05:14:31 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080516162022.41ee0b07@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I wonder if doing this generically with existing bridge code would
> be a better approach. It seems like the TOE problem all over again,
> only this time it is Traffic Control offload. Sorry, just because
> you can do it in hardware doesn't mean it is a good thing.

How is this anything like TOE?  We're not bypassing the stack, we're not
inserting any exit points in the stack, it's just another way the
hardware can schedule traffic internally to itself.  But there needs to
be a mechanism to configure it.  We have 4 options.  1) Do nothing.
This is very unattractive for 10 GbE devices, especially since a number
of 10 GbE devices have fairly complex and useful Tx and Rx advanced
features.  2) Insert these commands into ethtool.  This doesn't make
much sense, since most drivers around won't need these entry points to
the driver.  3) Embed the interface in the driver.  Jeff G. made a good
point that this isn't sustainable for the future, which I agree with.
This is a new standard in ethernet, so we should make the generic
interface.  4) Make the generic interface captured in the design doc
from the previous email from me in this thread.

All I'm proposing is 9 entry points into the drivers via netlink for
device configuration.  I'm not asking for a stack rewrite or insertion
into the stack to bypass the existing stack.

Cheers,
-PJ Waskiewicz
