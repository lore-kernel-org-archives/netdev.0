From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/3] net: dsa: Allow configuration of CPU & DSA port
 speeds/duplex
Date: Thu, 18 Jun 2015 03:11:59 +0200
Message-ID: <20150618011159.GA22072@lunn.ch>
References: <1434129537-15252-1-git-send-email-andrew@lunn.ch>
 <1434129537-15252-3-git-send-email-andrew@lunn.ch>
 <557F0CD5.4070705@gmail.com>
 <536480200.118000.1434564592107.JavaMail.zimbra@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	David <davem@davemloft.net>, Guenter Roeck <linux@roeck-us.net>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	netdev <netdev@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58072 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754254AbbFRBRy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 21:17:54 -0400
Content-Disposition: inline
In-Reply-To: <536480200.118000.1434564592107.JavaMail.zimbra@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 17, 2015 at 02:09:52PM -0400, Vivien Didelot wrote:
> Hi Andrew, All,
> 
> On 12/06/15 10:18, Andrew Lunn wrote:
> > By default, DSA and CPU ports are configured to the maximum speed the
> > switch supports. However there can be use cases where the peer device
> > port is slower. Allow a fixed-link property to be used with the DSA
> > and CPU port in the device tree, and use this information to configure
> > the port.
> 
> Would it be a good idea for DSA to expose the "cpu" port to userspace as well?
> That way, it'd be possible to use ethtool to set the port speed and duplex
> mode, or dump registers (this would have saved me quite some time in dev).

I have code which expose these via debugfs. So far, i have all
registers, stats, ATU, and the scratch registers. For the patches to
apply cleanly, they depend on these patches, so i've not posted them
yet.

I'm not strongly against having a CPU port, but i don't particularly
like having the CPU port as an interface. And when you get to cascaded
switches, the DSA ports are also interesting, so should we also have a
netdev for them? But they are equally useless for transferring frames
from the host as the CPU port. This is why i went for debugfs.

> 
> Also, in my RFC for 802.1Q support [1], I assume the CPU port to be a tagged
> member of each VLAN. But someone may want to add a VLAN with swp3 and swp4
> only, and another VLAN with swp0, swp1 and the CPU port. Am I correct?

The DSA concept is that switch ports are separate interfaces. So
adding a VLAN to two ports does to automatically bridge those ports
together. You need to add them to a bridge as well before VLAN tagged
frames are bridged between ports.

       Andrew
