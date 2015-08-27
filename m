From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 0/2] Add new switchdev device class
Date: Thu, 27 Aug 2015 09:45:25 +0200
Message-ID: <20150827074525.GA8094@lunn.ch>
References: <1440659806-56582-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@resnulli.us, davem@davemloft.net,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40678 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751824AbbH0Hw4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2015 03:52:56 -0400
Content-Disposition: inline
In-Reply-To: <1440659806-56582-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I don't know about how this overlaps with DSA platform_class.  Florian?

There is some overlap with DSA, but the current DSA model, with
respect to probing, is broken. So this might be interesting as a way
towards fix that.

One thing to keep in mind is the D in DSA. You talk about switch,
singular. DSA has a number of switches in a cluster. We currently
export a single switchdev interface for the cluster, but there are
some properties which are per switch, e.g. temperature, eeprom
contents, statistics, power management etc.


Although ethtool does have options for these, it is not always a
natural fit. ethtool --eeprom-dump on a switch port dumps the switch
EEPROM, and all ports on the switch can be used. --register-dump on a
port is good for showing the per ports registers, but there is no
natural interface for showing the global switch registers. Florian's
resent L2 interface patch shows we have issues getting access to the
'cpu' port, the port which interfaces to the host.

We need to be careful that any new interfaces we add are better at
representing the true structure of the hardware, which includes there
being multiple physical switches below a switchdev, and they are
connected together by ports which are currently not visible as
netdevs.

      Andrew
