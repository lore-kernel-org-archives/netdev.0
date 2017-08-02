From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/2] [for 4.13] net: qcom/emac: disable flow control
 autonegotiation by default
Date: Wed, 2 Aug 2017 13:48:18 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD00490C0@AcuExch.aculab.com>
References: <1501623460-3575-1-git-send-email-timur@codeaurora.org>
 <1501623460-3575-2-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Timur Tabi' <timur@codeaurora.org>,
        "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.192]:54882 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751895AbdHBNsZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 09:48:25 -0400
In-Reply-To: <1501623460-3575-2-git-send-email-timur@codeaurora.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi
> Sent: 01 August 2017 22:38
> The EMAC has a curious qwirk when RX flow control is enabled and the
> kernel hangs.  With the kernel hung, the EMAC's RX queue soon fills.
> If RX flow control is enabled, the EMAC will then send a non-stop
> stream of pause frames until the system is reset.  The EMAC does not
> have a built-in watchdog.
> 
> In various tests, the pause frame stream sometimes overloads nearby
> switches, effectively disabling the network.
...

If the nearby switches cannot handle pause frames, then the MAC shouldn't
be sending them at all.
They

I suspect that they should only ever be sent if the phy autonegotiation
indicates that they are supported.
You might want to avoid sending them even if allowed, or advertise
non-support on hardware that could support them, but sending them
anyway is likely to cause grief.

This is similar to the problems that arise when the 'speed' is forced
instead of limiting the advertised speed to one value.

	David
