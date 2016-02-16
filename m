From: <Bryan.Whitehead@microchip.com>
Subject: RE: [PATCH net-next,V2] Add LAN9352 Ethernet Driver
Date: Tue, 16 Feb 2016 19:41:46 +0000
Message-ID: <90A7E81AE28BAE4CBDDB3B35F187D264402EFB12@CHN-SV-EXMX02.mchp-main.com>
References: <90A7E81AE28BAE4CBDDB3B35F187D264402EF4A2@CHN-SV-EXMX02.mchp-main.com>
 <56BD40F1.2030707@gmail.com> <20160212072040.GC8046@lunn.ch>
 <90A7E81AE28BAE4CBDDB3B35F187D264402EF5BB@CHN-SV-EXMX02.mchp-main.com>
 <20160212171829.GD13273@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <f.fainelli@gmail.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp01.microchip.com ([198.175.253.37]:59194 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932451AbcBPTls convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 14:41:48 -0500
In-Reply-To: <20160212171829.GD13273@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew,

At this point, I am not tasked with implementing switch features, which would likely take a long time to complete.

If it is too difficult to add switch features later, then they may come as an entirely new driver at that time.

So this driver should only be thought of as operating a single port ethernet controller.

Bryan

-----Original Message-----
From: Andrew Lunn [mailto:andrew@lunn.ch] 
Sent: Friday, February 12, 2016 12:18 PM
To: Bryan Whitehead - C21958
Cc: f.fainelli@gmail.com; davem@davemloft.net; netdev@vger.kernel.org
Subject: Re: [PATCH net-next,V2] Add LAN9352 Ethernet Driver

> At this point my plan is to just get a basic Ethernet controller 
> driver submitted, and later work on switch features.

They are not really separable. 

The linux way of dealing with switches is to model each port as a net device. So you should have a lan0 device and a lan1 device for this two port switch. You can put IP addresses on the ports, and use them as separate ports. If you want to bridge the two ports, you create a linux bridge and add the ports to the bridge. Using netdev or DSA, you can then push this configuration down to the hardware, so it performs the actual bridging of packets between ports.

    Andrew
