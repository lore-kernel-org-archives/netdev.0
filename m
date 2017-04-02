From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 10/13] ftgmac100: Add a reset task and use it for link
 changes
Date: Mon, 03 Apr 2017 07:05:50 +1000
Message-ID: <1491167150.26047.14.camel@kernel.crashing.org>
References: <20170402033523.9482-1-benh@kernel.crashing.org>
         <20170402033523.9482-11-benh@kernel.crashing.org>
         <20170402184237.GB5189@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:52065 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750826AbdDBVF7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 2 Apr 2017 17:05:59 -0400
In-Reply-To: <20170402184237.GB5189@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-04-02 at 20:42 +0200, Andrew Lunn wrote:
> Have you run lockdep tests on this? I think it is normal to take the
> rtnl lock first, then the phydev lock. Try some ethtool operations
> and see if you get a splat.

You are right. I actually realized that was wrong last night ;-) It
will splat with the order in open/close.

Just a stupid thinko (I added the phy lock in a second pass). I'll
fix that.

> Also, do you need to be worried about mdio operations? Do you need to
> take that lock as well, since there might be other PHYs, or an
> Ethernet switch on the bus?

There could be I suppose, none of the setups I've seen with those
SoC has done it but nothing prevents it, I'll have a look.

Thanks.
Ben.
