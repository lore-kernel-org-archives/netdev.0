From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 0/8] net: dsa: New registration API
Date: Thu, 30 Apr 2015 09:50:36 -0700
Message-ID: <55425D5C.1020101@gmail.com>
References: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com> <20150430131216.GC22831@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	cphealy@gmail.com, mathieu@codeaurora.org, jonasj76@gmail.com,
	andrey.volkov@nexvision.fr, Chris.Packham@alliedtelesis.co.nz
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:34759 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751272AbbD3Qur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 12:50:47 -0400
Received: by pdbqa5 with SMTP id qa5so66035451pdb.1
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 09:50:47 -0700 (PDT)
In-Reply-To: <20150430131216.GC22831@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/04/15 06:12, Andrew Lunn wrote:
>> Note that there are currenlty no incompatibles changes made to existing Device
>> Tree sources, rather, depending on the bus we are probed for, e.g: MDIO
>> the dsa,mii-bus and dsa,ethernet phandles and first cell of the  "reg" property
>> will become obsolete, everything else remains entirely compatible. 
> 
> Hi Florian
> 
> I'm not sure dsa,mii-bus and dsa,ethernet will become obsolete. At
> least they are probably needed for multi switch setups, and the
> possible but probably unlikely multi DSA setups.
> 
> You cannot assume that dsa,mii-bus and dsa,ethernet have the same
> parent. In a multi switch setup, it could be there is an mdio-mux in
> the picture. So all your probe really tells you, is that there is a
> switch on this mii bus, but you don't know what ethernet it is hanging
> off.

Good point.

> 
> The switch could be hanging off multiple ethernets. I'm working on
> supporting this for the WRT1900AC, where i use the bond driver on the
> host side. So dsa,ethernet is a phandle to a bond interface.

Humm, bond is a software constructs, don't you rather want two phandles
to the relevant Ethernet interfaces instead and then learn through
netlink/netdevice notifiers that these are eventually part of the same bond?

> 
> The probe is likely to find all switches in a multi switch setup. But
> i guess we only want the probe of the root devices in a switch tree to
> cause a DSA setup.

Right.

> 
> So i think there needs to be some matching performed when looking in
> the device tree. The dsa,mii-bus and address discovered by probing
> need to match what is in the DSA properties.

Sure, that's a good point. I tried to start with simple case first, if
you can recommend consumer/off the shelf hardware which has a cascaded
setup, that could help too.

The configuration I have access to with Broadcom switches looks like
this: internal SF2 switch MMIO-mapped, with an external RGMII interface
to a MDIO connected BCM53125 switch.

so this not a true switch tree here, they can (and should) be treated as
different switch trees, attached to different interfaces: eth0 for CPU
for the internal one and the DSA-created "rgmii" interface for the
second switch.
-- 
Florian
