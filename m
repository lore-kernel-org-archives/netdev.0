From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 1/8] dsa: mv88e6xxx: Prepare for turning this into a library module
Date: Thu, 14 Apr 2016 16:22:08 -0400
Message-ID: <874mb454b3.fsf@ketchup.mtl.sfl>
References: <1460591998-20598-1-git-send-email-andrew@lunn.ch> <1460591998-20598-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48617 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751936AbcDNUWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 16:22:12 -0400
In-Reply-To: <1460591998-20598-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> Export all the functions so that we can later turn the module into a
> library module.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Sorry but I don't like this. We don't want one module per 88E6xxx switch
model. We need one driver supporting them all, like any other driver.

Multiple modules will continue to confuse us with duplicated code. For
instance, every specific mv88e6*_setup_global functions program the
switch's DSA device number with something like:

    REG_WRITE(REG_GLOBAL, GLOBAL_CONTROL_2, ds->index & 0x1f);

Looking at every drivers/net/dsa/mv88e6*.c file, there are only few
differences in their dsa_switch_driver structures:

The .setup function is always specific, but easily factorizable in a
mv88e6xxx_setup function. The .probe function can be merged once we have
a single driver. mv88e6131 has different phy_{read,write} functions
which can be abstracted in mv88e6xxx_phy_{read,write}. Only mv88e6352
has support for the EEPROM, which is simple to abstract too.

I'm working on a few patches right away to factorize this and lighten up
that part from your current refactoring of DSA.

Here's an example of duplicated code fixed for the 6131 PHY access code:

    http://ix.io/wJm

Thanks,
Vivien
