From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 0/2] Indirect phy access for mv88e6171
Date: Sun, 15 Feb 2015 13:05:12 -0800
Message-ID: <CAGVrzcYDLksA3gbJFypgp+f3BreMTTD5roHecoKm67M7qExOtg@mail.gmail.com>
References: <1423937871-9180-1-git-send-email-andrew@lunn.ch>
 <54E0E648.8080206@roeck-us.net> <20150215202511.GH3213@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Guenter Roeck <linux@roeck-us.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:49777 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754889AbbBOVFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 16:05:53 -0500
Received: by mail-ig0-f170.google.com with SMTP id l13so26903644iga.1
        for <netdev@vger.kernel.org>; Sun, 15 Feb 2015 13:05:53 -0800 (PST)
In-Reply-To: <20150215202511.GH3213@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-02-15 12:25 GMT-08:00 Andrew Lunn <andrew@lunn.ch>:
>> I'll try. My primary problem right now is that I run Lennert Buytenhek's
>> patch set to support bridging offload (aka hardware bridging) on top of
>> the upstream dsa code, and the upstream code now supports a competing /
>> alternate means  to support bridging/switching offload (NET_SWITCHDEV)
>> which doesn't work with dsa (at least not yet). So I'll have to figure
>> out if / how I can run your patches with my code base, or how I can add
>> add support for NET_SWITCHDEV into dsa.
>
> We should be adding switchdev support to DSA for hardware
> bridging. The concepts in Lennert Buytenhek's should be a good
> starting point for this.

In fact, there is not much to be implemented in DSA, since we already
have everything in place in net-next now:

- net_device notifier to learn which ports are leaving/joining the bridge
- hook an abstraction for ndo_switch_port_stp_update
- hook an abstraction for ndo_fdb_{add,del,dump}

>
>> Do you know if there are any efforts going on in that direction ?
>
> Florian has expressed an interest in getting hardware bridging
> working. I've no idea if he has looked at it from the perspective of
> switchdev.

I have some patches that leverage the switchdev-related patches and
bring an abstraction to DSA, they should not be fundamentally
different at the DSA driver level, since most of the abstraction is
done in net/dsa/slave.c, I plan on posting these patches tomorrow once
I am back home. I tested these with the bcm_sf2 driver, so testing
with Marvell hardware would be more than welcome.

Thanks!
-- 
Florian
