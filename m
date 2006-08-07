From: Philip Craig <philipc@snapgear.com>
Subject: Re: [RFC] gre: transparent ethernet bridging
Date: Mon, 07 Aug 2006 11:55:14 +1000
Message-ID: <44D69D82.1090407@snapgear.com>
References: <44CDD631.5030008@snapgear.com> <20060731091423.3327f85e@dxpl.pdx.osdl.net> <44CEAB31.5090501@snapgear.com> <20060731220822.444f04e4@localhost.localdomain> <20060802074223.GA23715@xi.wantstofly.org> <44D15265.4090905@snapgear.com> <20060803073307.GA29775@xi.wantstofly.org> <44D1BE93.1080308@snapgear.com> <20060803194016.GC527@xi.wantstofly.org> <44D29C47.6080407@snapgear.com> <20060804080236.GA4106@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.snapgear.com ([203.143.235.140]:9934 "EHLO
	cyberguard.com.au") by vger.kernel.org with ESMTP id S1750883AbWHGBzQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Aug 2006 21:55:16 -0400
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20060804080236.GA4106@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lennert Buytenhek wrote:
> I have one machine at home that appears to be on my employer's network
> via such a tunnel.  I don't use bridging, because I don't need any other
> machine at home to access this tunnel.  I do want bridging, and not proxy
> ARP, because it allows me to run arpwatch, and doesn't require me to
> reconfigure something at the remote end if I, for example, want to add
> another IP address to my home box.

Okay.
If this is using Linux, do you have a patch that does this already?

> No, just send it to the device that matches the lower-level protocol.
> So if you receive an ethernet packet, make it be received on the ethernet
> sub-device, if it's IP, make it be received on the IP sub-device, etc.
> 
> Note that I'm not saying that this is necessarily a good idea, it's just
> what I would suggest if you want to run both 'bare IP' and ethernet
> encapsulated traffic over the same GRE tunnel at the same time.  (Not sure
> why you'd want that.)

I still don't understand what the IP sub-device is, or whether
this is different from the options I list below.
But I don't have a good reason for wanting this either.
So lets forget about this and talk about the three options below.

>> This seems cleaner to me:
>> The GRE tunnel receives a packet of any protocol (ethernet included),
>> and adds the IP/GRE header.  Anything else is done above GRE.
>> Whatever needs the ethernet header should add it.
>>
>> And then the decision is, how do we add the ethernet header?
>> - an option to GRE to always add the ethernet header
> 
> I think I lost you here.  You surely can't just 'make up' any ethernet
> header?

No, you need a device that looks like an ethernet device.
We can modify the GRE device to look like ethernet (as an option).
Or we can create a new ethernet device stacked on top of the GRE device.
Or we can use the bridge device, which already looks like ethernet.

My first patch in this thread did it by modifying the GRE device.
Look at that patch if my explanation still doesn't make sense.
The option part is controlled by the "#if 0" in that patch
(which needs fixing of course).

You have a valid use that doesn't need bridging, so IMO we can rule
out doing it in the bridging code.

