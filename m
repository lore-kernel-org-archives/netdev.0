From: Oliver Martin <oliver.martin@student.tuwien.ac.at>
Subject: ep93xx_eth PHY problems
Date: Tue, 04 Mar 2008 14:02:15 +0100
Message-ID: <47CD4857.2060406@student.tuwien.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hvr@gnu.org, buytenh@wantstofly.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.185]:52438 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760726AbYCDNDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 08:03:10 -0500
Received: by mu-out-0910.google.com with SMTP id i10so3065454mue.5
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2008 05:03:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I was having problems with the ep93xx_eth driver: apparently the PHY
auto-negotiated "100/full" with the switch, but the driver didn't care
about it (or is it the other way round?). This led to lots of packets
being dropped under load. Anyway, the patch that was posted last
november (http://marc.info/?l=linux-netdev&m=119520642207001&w=4)
helped.

Now I'm having different problems: When auto-negotiation is enabled, it 
sometimes randomly changes the link state:

PHY: 0:01 - Link is Down
PHY: 0:01 - Link is Up - 100/Full

PHY: 0:01 - Link is Up - 100/Half
PHY: 0:01 - Link is Up - 100/Full

PHY: 0:01 - Link is Up - 10/Half
PHY: 0:01 - Link is Up - 100/Full

It could be related to some kind of error handling - often, when this
happens, our test (a simple RFC 862 UDP echo server, see [1]) loses 
packets, but the message seems to appear only after the test fails.

If I disable auto-negotiation with ethtool, it first changes to the mode
I choose, but seconds later changes to "1000/Full":

PHY: 0:01 - Link is Up - 100/Full
PHY: 0:01 - Link is Up - 1000/Full

This is obviously impossible, and while it mostly works, it seems to
confuse something (PHY? MAC? driver?), as there seem to be more dropped
packets than with the Cirrus 2.4 driver (on a TS-7260 with the default
TS-Linux).

Maybe some error condition isn't handled properly, causing both the 
packet loss and the PHY state change? Of course, I'm just speculating 
and it might be something entirely different.

Any ideas?

-- 
Oliver

[1] http://murli.34sp.com/o/ep93xx-eth/echo/
