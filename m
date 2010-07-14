From: David Miller <davem@davemloft.net>
Subject: Re: Raise initial congestion window size / speedup slow start?
Date: Wed, 14 Jul 2010 11:15:53 -0700 (PDT)
Message-ID: <20100714.111553.104052157.davem@davemloft.net>
References: <4C3D94E3.9080103@wildgooses.com>
	<4C3DD5EB.9070908@tmr.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lists@wildgooses.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: davidsen@tmr.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48897
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751721Ab0GNSPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 14:15:38 -0400
In-Reply-To: <4C3DD5EB.9070908@tmr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bill Davidsen <davidsen@tmr.com>
Date: Wed, 14 Jul 2010 11:21:15 -0400

> You may have to go into /proc/sys/net/core and crank up the
> rmem_* settings, depending on your distribution.

You should never, ever, have to touch the various networking sysctl
values to get good performance in any normal setup.  If you do, it's a
bug, report it so we can fix it.

I cringe every time someone says to do this, so please do me a favor
and don't spread this further. :-)

For one thing, TCP dynamically adjusts the socket buffer sizes based
upon the behavior of traffic on the connection.

And the TCP memory limit sysctls (not the core socket ones) are sized
based upon available memory.  They are there to protect you from
situations such as having so much memory dedicated to socket buffers
that there is none left to do other things effectively.  It's a
protective limit, rather than a setting meant to increase or improve
performance.  So like the others, leave these alone too.
