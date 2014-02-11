From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [RFC 2/2] xen-netback: disable multicast and use a random hw
 MAC address
Date: Tue, 11 Feb 2014 08:43:25 +0000
Message-ID: <1392108205.22033.16.camel@dagon.hellion.org.uk>
References: <1392071391-13215-1-git-send-email-mcgrof@do-not-panic.com>
	 <1392071391-13215-3-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	"Luis R. Rodriguez" <mcgrof@suse.com>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	"Wei Liu" <wei.liu2@citrix.com>
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:20719 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812AbaBKIn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 03:43:27 -0500
In-Reply-To: <1392071391-13215-3-git-send-email-mcgrof@do-not-panic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-02-10 at 14:29 -0800, Luis R. Rodriguez wrote:
> From: "Luis R. Rodriguez" <mcgrof@suse.com>
> 
> Although the xen-netback interfaces do not participate in the
> link as a typical Ethernet device interfaces for them are
> still required under the current archtitecture. IPv6 addresses
> do not need to be created or assigned on the xen-netback interfaces
> however, even if the frontend devices do need them, so clear the
> multicast flag to ensure the net core does not initiate IPv6
> Stateless Address Autoconfiguration.

How does disabling SAA flow from the absence of multicast? Surely these
should be controlled logically independently even if there is some
notional linkage. Can SAA not be disabled directly?

>  Clearing the multicast
> flag is required given that the net_device is using the
> ether_setup() helper.
> 
> There's also no good reason why the special MAC address of
> FE:FF:FF:FF:FF:FF is being used other than to avoid issues
> with STP,

With your change there is a random probability on reboot that the bridge
will end up with a randomly generated MAC address instead of a static
MAC address (usually that of the physical NIC on the bridge), since the
bridge tends to inherit the lowest MAC of any port.

Since IP configuration is done on the bridge this will break DHCP,
whether it is using static or dynamic mappings from MAC to IP address,
and the host will randomly change IP address on reboot.

So Nack for that reason.

>  since using this can create an issue if a user
> decides to enable multicast on the backend interfaces

Please explain what this issue is.

Also how can a user enable multicast on the b/e? AFAIK only Solaris ever
implemented the m/c bits of the Xen PV network protocol (not that I
wouldn't welcome attempts to add it to other platforms)

Ian.
