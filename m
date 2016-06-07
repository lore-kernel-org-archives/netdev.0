From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 5/5] net: dsa: bcm_sf2: Register our slave
 MDIO bus
Date: Tue, 7 Jun 2016 12:29:52 -0700
Message-ID: <575720B0.3040901@gmail.com>
References: <1465254895-11152-1-git-send-email-f.fainelli@gmail.com>
 <1465254895-11152-6-git-send-email-f.fainelli@gmail.com>
 <87oa7dxdis.fsf@ketchup.mtl.sfl> <87r3c9vtay.fsf@ketchup.mtl.sfl>
 <20160607170050.GA28994@lunn.ch> <87oa7cx5sx.fsf@ketchup.mtl.sfl>
 <20160607184420.GB28994@lunn.ch> <87vb1kke5u.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34735 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752248AbcFGT34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 15:29:56 -0400
Received: by mail-pf0-f171.google.com with SMTP id 62so80656485pfd.1
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 12:29:56 -0700 (PDT)
In-Reply-To: <87vb1kke5u.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/07/2016 12:11 PM, Vivien Didelot wrote:
> Hi Andrew,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
>>>> With the legacy interface it is tricky. When would you call such a
>>>> remove/tairdown function when using the old binding?
>>>
>>> That'd go in dsa_switch_destroy I guess, but it just covers the case
>>> where the whole DSA code is unloaded...
>>
>> I don't think that helps you. It should not be possible to unload the
>> DSA core while there is an active driver. The drivers needs to unload
>> first....
> 
> Well, dsa_switch_destroy() is where ds->slave_mii_bus gets unregistered
> (if registered by the framework), so it seems fair to do something like:
> 
>     if (ds->drv->shutdown)
>         ds->drv->shutdown(ds);
> 
> But I'm still not sure if it is worth it to add a new legacy specific
> function to DSA drivers, unless there is a use case for such optional
> teardown callback for the new bindings too.

The new binding requires the use of dsa_unregister_switch() so this is
where all the teardown and resource freeing should occur.

I do not really think it is worth trying to fix the old binding and
support code now, unless we want to migrate it somehow to using the code
from net/dsa/dsa2.c.
-- 
Florian
