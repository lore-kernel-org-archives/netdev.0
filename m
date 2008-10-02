From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [PATCH] e1000e: write protect ICHx NVM to prevent malicious write/erase
Date: Thu, 2 Oct 2008 08:37:40 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52064FB19B@orsmsx418.amr.corp.intel.com>
References: <20081002001830.5951.3123.stgit@jbrandeb-bw.jf.intel.com> <20081002001835.5951.82533.stgit@jbrandeb-bw.jf.intel.com> <Pine.LNX.4.64.0810021500470.1887@twin.jikos.cz>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <torvalds@linux-foundation.org>, <jeff@garzik.org>,
	<davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <arjan@linux.intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>, <arjan@linux.intel.com>
To: "Jiri Kosina" <jkosina@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:23631 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753797AbYJBPhm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 11:37:42 -0400
Content-class: urn:content-classes:message
In-Reply-To: <Pine.LNX.4.64.0810021500470.1887@twin.jikos.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Kosina wrote:
>> Set the hardware to ignore all write/erase cycles to the GbE region
>> in the ICHx NVM.  This feature can be disabled by the
>> WriteProtectNVM module parameter (enabled by default) only after a
>> hardware reset, but 
>> the machine must be power cycled before trying to enable writes.

> Does this impose any user-visible behavior change? (such as not being
> able to set up wake-on-lan, change MAC address, whatever).

no, because none of that is stored permanently in the eeprom unless you
do writes with ethtool -E.  Our policy for the driver is generally don't
ever write to the eeprom.  So all the normal paths (except for initial
start on preproduction hardware and ethtool -E writes) do not write to
the eeprom.

Currently the driver will let you try to commit a change but with this
patch it will never get written to NVM unless you reboot, load driver
(the first time!) with WriteProtectNVM=0 and *then* do ethtool -E.
