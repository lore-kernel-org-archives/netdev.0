From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: sky2 hangs, hw csum errors with 2.6.18
Date: Fri, 22 Sep 2006 11:31:52 -0700
Message-ID: <20060922113152.02874cbc@localhost.localdomain>
References: <20060922112442.GB4161@dezo.moloch.sk>
	<20060922095642.5acf4ac9@dxpl.pdx.osdl.net>
	<20060922182924.GE4161@dezo.moloch.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:61591 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964873AbWIVScC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 14:32:02 -0400
To: Martin Lucina <mato@kotelna.sk>
In-Reply-To: <20060922182924.GE4161@dezo.moloch.sk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 22 Sep 2006 20:29:25 +0200
Martin Lucina <mato@kotelna.sk> wrote:

> shemminger@osdl.org said:
> > You can turn off TX pause and get the same effect.
> 
> Not sure if I did the right thing, but:
> 
> # ifdown eth1
> ...
> # ethtool -A eth1 tx off
> # ethtool -a eth1
> Pause parameters for eth1:
> Autonegotiate:	on
> RX:		on
> TX:		off
> # ifup eth1
> ...
> sky2 eth1: enabling interface
> sky2 eth1: Link is up at 1000 Mbps, full duplex, flow control both
> # ethtool -a eth1
> Pause parameters for eth1:
> Autonegotiate:	on
> RX:		on
> TX:		on
> 
> is this what I should be seeing?
> 
> -mato


To get tx flow control to turn off. You need a patch (already in netdev-2.6 upstream)
and then you can do:

	ethtool -A eth1 autoneg off tx off

-- 
Stephen Hemminger <shemminger@osdl.org>
