From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC PATCH 13/16] net: dsa: mv88e6xxx: Refactor MDIO so driver registers mdio bus
Date: Fri, 27 May 2016 15:45:46 -0400
Message-ID: <8760tzz3md.fsf@ketchup.mtl.sfl>
References: <1464312050-23023-1-git-send-email-andrew@lunn.ch> <1464312050-23023-14-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	John Crispin <john@phrozen.org>, Bryan.Whitehead@microchip.com,
	Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:36713 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753862AbcE0Tpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 15:45:49 -0400
In-Reply-To: <1464312050-23023-14-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

I like the s/phy/mdio/ renaming, but please move it in its own
non-functional patch for easier reviewing.

Also, we may want to use this opportunity to get rid of some _ prefixed
functions. It is hard to following the distinction between these two
following signatures:

    int _mv88e6xxx_mdio_read(struct mv88e6xxx_priv_state *ps, int addr, int reg_num)

and

    int mv88e6xxx_mdio_read(struct mii_bus *bus, int port, int regnum)

(which take different first argument.)

It would be great to introduce here the two low-level, bus-agnostic,
SMI unlocked functions: mv88e6xxx_read() and mv88e6xxx_write().

Thanks,

        Vivien
