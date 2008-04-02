From: Andy Fleming <afleming@freescale.com>
Subject: Re: [Pasemi-linux] I2C MDIO support for pasemi_mac driver
Date: Wed, 2 Apr 2008 17:45:38 -0500
Message-ID: <C3F69A6B-85D0-4FB4-834E-958A21C7577A@freescale.com>
References: <1204911643.8864.15.camel@localhost.localdomain> <20080307183738.GA22366@lixom.net>  <20080307184854.GA23402@lixom.net> <1205445473.8864.171.camel@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Olof Johansson <olof@lixom.net>, netdev@vger.kernel.org,
	pasemi-linux@ozlabs.org
To: Nate Case <ncase@xes-inc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:33172 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754223AbYDBWpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 18:45:53 -0400
In-Reply-To: <1205445473.8864.171.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mar 13, 2008, at 16:57, Nate Case wrote:

> On Fri, 2008-03-07 at 12:48 -0600, Olof Johansson wrote:
>> On second thought, it might be a better idea to change from BUS:ID to
>> BUSTYPE:BUS:ID in phylib, to separate the namespaces.
>>
>> That, plus a way to get to an i2c bus number from a device tree node,
>> and we should be all set. That might be tricker though.
>
> This turned out to not be as invasive of a change as I thought.   
> Here's
> my first attempt at it.  The changes to pasemi_mac are based on your
> first patch but modified accordingly for the new bus type field.
>
> Comments are welcome.  Patch is against 2.6.23 for now (though I
> wouldn't expect any of these areas to have changed much since then).
> After I get some feedback I can rebase against the latest netdev and  
> do
> a formal submission.


Sorry, I should have responded to this when it arrived.

My first instinct is that the current bus->id shouldn't be an int at  
all (well, obviously not my *first* instinct, since that's what I did  
the first time through).  So I like the idea of including a label in  
the bus, but I'm not sure if it's necessary to add a new field.   
Instead, I'd like to see bus->id converted to a char * or char [].  I  
played around with this a bit today, and it requires a little more  
work than it might at first seem, but is quite doable.

The question is whether that would solve your problem.  I think you  
would then be able to register buses with the id "pas_gpio:xxx" or  
"i2c:xxx", etc.

Anyway, I'm sending a patch which does that as an RFC in a follow-on  
email.  A part of me thinks adding bus->type might be good, whether  
it's the final solution or not.

Andy
