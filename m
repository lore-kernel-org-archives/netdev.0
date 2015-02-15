From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 0/2] Indirect phy access for mv88e6171
Date: Sun, 15 Feb 2015 14:20:47 -0800
Message-ID: <54E11BBF.30303@roeck-us.net>
References: <1423937871-9180-1-git-send-email-andrew@lunn.ch> <54E0E648.8080206@roeck-us.net> <20150215202511.GH3213@lunn.ch> <CAGVrzcYDLksA3gbJFypgp+f3BreMTTD5roHecoKm67M7qExOtg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:35267 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754735AbbBOWUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 17:20:52 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YN7YY-001FRe-Oi
	for netdev@vger.kernel.org; Sun, 15 Feb 2015 22:20:51 +0000
In-Reply-To: <CAGVrzcYDLksA3gbJFypgp+f3BreMTTD5roHecoKm67M7qExOtg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/15/2015 01:05 PM, Florian Fainelli wrote:
> 2015-02-15 12:25 GMT-08:00 Andrew Lunn <andrew@lunn.ch>:
>>> I'll try. My primary problem right now is that I run Lennert Buytenhek's
>>> patch set to support bridging offload (aka hardware bridging) on top of
>>> the upstream dsa code, and the upstream code now supports a competing /
>>> alternate means  to support bridging/switching offload (NET_SWITCHDEV)
>>> which doesn't work with dsa (at least not yet). So I'll have to figure
>>> out if / how I can run your patches with my code base, or how I can add
>>> add support for NET_SWITCHDEV into dsa.
>>
>> We should be adding switchdev support to DSA for hardware
>> bridging. The concepts in Lennert Buytenhek's should be a good
>> starting point for this.
>
> In fact, there is not much to be implemented in DSA, since we already
> have everything in place in net-next now:
>
> - net_device notifier to learn which ports are leaving/joining the bridge
> - hook an abstraction for ndo_switch_port_stp_update
> - hook an abstraction for ndo_fdb_{add,del,dump}
>
>>
>>> Do you know if there are any efforts going on in that direction ?
>>
>> Florian has expressed an interest in getting hardware bridging
>> working. I've no idea if he has looked at it from the perspective of
>> switchdev.
>
> I have some patches that leverage the switchdev-related patches and
> bring an abstraction to DSA, they should not be fundamentally
> different at the DSA driver level, since most of the abstraction is
> done in net/dsa/slave.c, I plan on posting these patches tomorrow once
> I am back home. I tested these with the bcm_sf2 driver, so testing
> with Marvell hardware would be more than welcome.
>

Sounds good. I would be more than happy to test the code with the
Marvell hardware.

My current status is that I got Lennert's patches running on top of
the latest version of the dsa code, including the switchdev changes.
It currently uses ndo_switch_port_stp_update, but I still have
ndo_bridge_join, ndo_bridge_leave, and ndo_bridge_port_flush
as added callbacks.

Guenter
