From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: Acer Aspire 1524WLMi and RealTek 8169 - very slow
Date: Wed, 26 Jan 2005 14:00:22 -0800
Message-ID: <C925F8B43D79CC49ACD0601FB68FF50C02F5823B@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Richard Dawe" <rich@phekda.gotadsl.co.uk>,
        "Francois Romieu" <romieu@fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> If I try setting the speed & duplex using something like this:
> 
>    ethtool -s eth0 speed 10 duplex half
> 
> it fails. I get no errors, but the "ethtool eth0" shows the link speed
&
> duplex to be 100Mbps full-duplex. I think I managed to get it into
> 100Mbps half-duplex once
> 
> When I try to "ethtool -s eth0 speed 10", the link lights on my ADSL
> router change to orange, which indicates 10Mbps. Then the light goes
out
> and comes back green, which indicates 100Mbps.
> 
> So maybe the driver isn't waiting long enough for something.

You're running into the (in)famous ethtool vs autonegotiation issue.

If you do ethtool -s eth0 autoneg off speed 10 duplex half

I think it will probably work.  The behavior you're describing applies
to most drivers I think.  I actually vote that we get ethtool to
automatically turn autoneg off when someone forces speed _and_ duplex,
as its always the right thing to do.

Anyway, good luck.

Jesse
