From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v4 0/3] net: dsa: mv88e6xxx: add support for VLAN Table
 Unit
Date: Wed, 8 Jul 2015 22:08:52 +0200
Message-ID: <20150708200852.GD1357@lunn.ch>
References: <1436303900-24259-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <20150708143805.GA32208@lunn.ch>
 <894793886.88178.1436375596747.JavaMail.zimbra@savoirfairelinux.com>
 <20150708173216.GB1357@lunn.ch>
 <1831874541.91682.1436379099609.JavaMail.zimbra@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, David <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36524 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755638AbbGHUPM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jul 2015 16:15:12 -0400
Content-Disposition: inline
In-Reply-To: <1831874541.91682.1436379099609.JavaMail.zimbra@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > This is a limitation of the switch. So the driver needs to keep track
> > of which bridge a VLAN belongs to, if it is asked to accelerate the
> > same VLAN for a different bridge, it needs to say to the kernel,
> > sorry, cannot do that, and leave the kernel to do it in software.
> 
> Scott, how do you think this must be done? Returning a different error
> code when trying to add a SWITCHDEV_OBJ_PORT_VLAN object?
> Not sure how to query this fallback. Is -EOPNOTSUPP enough?

There was quite a bit of discussion about this a while back.  It
should return an error during the prepare phase. Looking at
__vlan_vid_add() and switchdev_fib_ipv4_add, it should return
EOPNOTSUPP.

	  Andrew
