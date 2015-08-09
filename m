From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCHv2 net-next] dsa: Support multiple MDIO busses
Date: Sun, 9 Aug 2015 20:26:42 +0300
Message-ID: <55C78D52.5040401@cogentembedded.com>
References: <1439083745-14169-1-git-send-email-andrew@lunn.ch>
 <55C749FD.8050303@cogentembedded.com> <20150809142030.GB14271@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:34405 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933115AbbHIR0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Aug 2015 13:26:44 -0400
Received: by lbbtg9 with SMTP id tg9so46147337lbb.1
        for <netdev@vger.kernel.org>; Sun, 09 Aug 2015 10:26:42 -0700 (PDT)
In-Reply-To: <20150809142030.GB14271@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/9/2015 5:20 PM, Andrew Lunn wrote:

>>> When using a cluster of switches, some topologies will have an MDIO
>>> bus per switch, not one for the whole cluster. Allow this to be
>>> represented in the device tree, by adding an optional mii-bus property
>>> at the switch level.

>>> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
>>> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
>>> ---

>>> v2: Fix documentation, which placed the properties documentation in
>>>      the wrong place.
>>> ---
>>>   Documentation/devicetree/bindings/net/dsa/dsa.txt |  5 +++++
>>>   net/dsa/dsa.c                                     | 12 +++++++++++-
>>>   2 files changed, 16 insertions(+), 1 deletion(-)

>>> diff --git a/Documentation/devicetree/bindings/net/dsa/dsa.txt b/Documentation/devicetree/bindings/net/dsa/dsa.txt
>>> index f0b4cd72411d..fc06f4a7c788 100644
>>> --- a/Documentation/devicetree/bindings/net/dsa/dsa.txt
>>> +++ b/Documentation/devicetree/bindings/net/dsa/dsa.txt
>>> @@ -32,6 +32,10 @@ A switch child node has the following optional property:
>>>   			  the presence and/or size of a connected EEPROM,
>>>   			  otherwise optional.
>>>
>>> +- mii-bus		: Should be a phandle to a valid MDIO bus device node.

>>     Why not call it "mdio-bus"?

> Hi Sergei

> What you cannot see in this hunk, but can in the file is:

> Marvell Distributed Switch Architecture Device Tree Bindings
> ------------------------------------------------------------

> Required properties:
> - compatible            : Should be "marvell,dsa"
> - #address-cells        : Must be 2, first cell is the address on the MDIO bus
>                            and second cell is the address in the switch tree.
>                            Second cell is used only when cascading/chaining.
> - #size-cells           : Must be 0
> - dsa,ethernet          : Should be a phandle to a valid Ethernet device node
> - dsa,mii-bus           : Should be a phandle to a valid MDIO bus device node
>
> The optional mii-bus properties i'm adding should be used in
> preference to this global one, for this switch. Keeping the names the
> same makes sense. But i did drop the dsa prefix to indicate it is
> local, not global scope,

    Dropping a vendor prefix usually means that it's (standardized) common 
property name. I don't know where you took the "local" scope thing...

> and all the other properties at switch level
> do not use the dsa prefix.

>      Andrew

MBR, Sergei
