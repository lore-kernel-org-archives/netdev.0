From: David Miller <davem@davemloft.net>
Subject: Re: BSD 4.2 style TCP keepalives
Date: Fri, 08 Jan 2010 17:41:38 -0800 (PST)
Message-ID: <20100108.174138.193059500.davem@davemloft.net>
References: <20100108124033.GA28782@hmsreliant.think-freely.org>
	<20100108.132107.38069748.davem@davemloft.net>
	<20100109012227.GA2762@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57160
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752519Ab0AIBla (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 20:41:30 -0500
In-Reply-To: <20100109012227.GA2762@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 8 Jan 2010 20:22:27 -0500

> I'm trying to do some independent computation on it, but its looking
> like this may have been a combination of old software (win2k) and a
> bad corner case in hardware.  I think the reporter has a NIC that
> doesn't do TCO properly on these old style keepalives, which would
> explain why it wasn't reproducable outside of the reporters
> environment.  I'm trying to figure out which card/hw revision of NIC
> they were using.  It might be worth coding an errata check into the
> appropriate driver if this all turns out to be accurate to disable
> TCO affectecd hw.

I think it's not a hardware bug, because there isn't anything
interesting about these packets from a checksumming perspective.

It's just a normal 1-byte TCP data frame as far as the card is
concerned.

Rather, I think when checksum offloading, win2k doesn't set the
internal packet state correctly for such probe packets such that the
card is told to checksum the frame.

Ie. a win2k TCP bug and nothing to do with the card or it's driver.
