From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 5/5] net: dsa: bcm_sf2: Register our slave MDIO bus
Date: Tue, 07 Jun 2016 12:48:37 -0400
Message-ID: <87r3c9vtay.fsf@ketchup.mtl.sfl>
References: <1465254895-11152-1-git-send-email-f.fainelli@gmail.com> <1465254895-11152-6-git-send-email-f.fainelli@gmail.com> <87oa7dxdis.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemlof.net, andrew@lunn.ch,
	Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:52340 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161503AbcFGQsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 12:48:41 -0400
In-Reply-To: <87oa7dxdis.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian, Andrew,

Vivien Didelot <vivien.didelot@savoirfairelinux.com> writes:

> Hum reviewing that again, I see that if one of the 2 subsequent calls to
> request_irq fails, you end up with an unregistered MDIO bus.
>
> We have the same issue in the mv88e6xxx legacy probe code if dsa.c fails
> to allocate the dsa_switch structure. I'm moving the MDIO register code
> to the setup function like you are doing here (good idea!) to fix that.

In fact it doesn't fix the issue because dsa_switch_driver doesn't
provide any remove/teardown function, in which mv88e6xxx and sf2 could
unregister their MDIO bus on switch removal.

Would it be worth it to add such optional function to DSA drivers?

Thanks,

        Vivien
