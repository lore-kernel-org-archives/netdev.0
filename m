From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH] net: mdio: of_mdio: check for already registered phy
 before creating new instances
Date: Thu, 08 May 2014 09:40:18 +0200
Message-ID: <536B34E2.2060408@zonque.org>
References: <1399389711-32716-1-git-send-email-zonque@gmail.com> <CAGVrzcY+3xeDzMAe1683+ypF59eMN9oTss6LC_rLShuEpmC4NA@mail.gmail.com> <536A58EF.4070206@gmail.com> <CAGVrzcZL7w8vRQ6-3NEqLK3VFHa-c1BMUVoaWSKmD2RXRedMCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:60011 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751509AbaEHHrk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2014 03:47:40 -0400
In-Reply-To: <CAGVrzcZL7w8vRQ6-3NEqLK3VFHa-c1BMUVoaWSKmD2RXRedMCw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On 05/07/2014 07:26 PM, Florian Fainelli wrote:
> 2014-05-07 9:01 GMT-07:00 Daniel Mack <zonque@gmail.com>:

>> Another solution would be to split mdiobus_register() and
>> create a mdiobus_register_noscan() or something, and then call that from
>> of_mdiobus_register().
> 
> That, or have a specific MDIO bus controller node boolean property
> such as  "mdio-bus-autoscan" or something similar which will tell
> of_mdiobus_register() not to override the phy_mask since the MDIO bus
> controller is capable of auto-detecting the PHYs present.
> 
> This should not be too controversial as we should really be describing
> a feature of the hardware here.

Hmm. Actually, we can't easily disable autoscanning for DT boards, with
or without the opt-in via "mdio-bus-autoscan", because that would force
all DT users to at least add this property, or add the sub-nodes
explicitly. Also, with "mdio-bus-autoscan", sub-nodes of the bus would
not be linked to the drivers' of_node pointer, which is confusing.

>From a DT user point of view, I believe that the behaviour with my patch
applied is most convenient: if sub-nodes are given, and their 'reg'
properties match the addresses of auto-probed phys, they are linked to
the existing instances, so their properties can be used by the drivers.
The only nasty detail is that, as the code stands, dev->of_node is not
available at the phy driver's .probe() callback but earliest in
.config_init().

I'll see if I find a nicer implementation.


Thanks,
Daniel
