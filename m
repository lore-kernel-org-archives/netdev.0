From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: Fri, 28 Sep 2007 13:20:38 -0700 (PDT)
Message-ID: <20070928.132038.35678834.davem@davemloft.net>
References: <ygfejgmea00.fsf@janus.isnogud.escape.de>
	<20070925.140910.41653604.davem@davemloft.net>
	<1190996839.18681.68.camel@chaos>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: urs@isnogud.escape.de, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, kaber@trash.net, joe@perches.com,
	oliver@hartkopp.net, oliver.hartkopp@volkswagen.de
To: tglx@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36210
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751120AbXI1UUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 16:20:38 -0400
In-Reply-To: <1190996839.18681.68.camel@chaos>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 28 Sep 2007 18:27:19 +0200

> I'm not inclined either way and we really should not make this a
> religious question whether that code goes in or not, especially not when
> we granted the mac80211 to export everything w/o _GPL suffix not too
> long ago.

This is because a wireless driver is a driver.  It can exist outside
of the kernel and it's mac80211 stack just like any other network
device driver.  ANd the interfaces in mac80211 are such that the
driver doesn't explicitly go into the internals of the implementation.

That's not true with CAN.

With this CAN stuff, any driver you write for it is intimately
integrated into the design and architecture of the CAN subsystem.  Any
such driver cannot stand on it's own.  Look at how these drivers can
get into the internals.

If this code goes in without the _GPL() exports, that's fine, but it's
setting incorrect expectations for people who think they can write
binary-only drivers and link to these symbols.

And it will be the CAN folks who are guilty of setting these
false premises.  Especially after I've explicitly warned about
it here.
