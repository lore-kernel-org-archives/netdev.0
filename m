From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 5/5] net: dsa: bcm_sf2: Register our slave MDIO bus
Date: Tue, 07 Jun 2016 15:11:09 -0400
Message-ID: <87vb1kke5u.fsf@ketchup.mtl.sfl>
References: <1465254895-11152-1-git-send-email-f.fainelli@gmail.com> <1465254895-11152-6-git-send-email-f.fainelli@gmail.com> <87oa7dxdis.fsf@ketchup.mtl.sfl> <87r3c9vtay.fsf@ketchup.mtl.sfl> <20160607170050.GA28994@lunn.ch> <87oa7cx5sx.fsf@ketchup.mtl.sfl> <20160607184420.GB28994@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	davem@davemlof.net
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:58503 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419AbcFGTLO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 15:11:14 -0400
In-Reply-To: <20160607184420.GB28994@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> > With the legacy interface it is tricky. When would you call such a
>> > remove/tairdown function when using the old binding?
>> 
>> That'd go in dsa_switch_destroy I guess, but it just covers the case
>> where the whole DSA code is unloaded...
>
> I don't think that helps you. It should not be possible to unload the
> DSA core while there is an active driver. The drivers needs to unload
> first....

Well, dsa_switch_destroy() is where ds->slave_mii_bus gets unregistered
(if registered by the framework), so it seems fair to do something like:

    if (ds->drv->shutdown)
        ds->drv->shutdown(ds);

But I'm still not sure if it is worth it to add a new legacy specific
function to DSA drivers, unless there is a use case for such optional
teardown callback for the new bindings too.

Thanks,

        Vivien
