From: David Miller <davem@davemloft.net>
Subject: Re: E100 RX ring buffers continued...
Date: Sat, 22 Aug 2009 18:15:52 -0700 (PDT)
Message-ID: <20090822.181552.152398363.davem@davemloft.net>
References: <m38whchrer.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58933
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933389AbZHWBPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Aug 2009 21:15:39 -0400
In-Reply-To: <m38whchrer.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Sat, 22 Aug 2009 16:09:00 +0200

> E100 RX buffers seem more problematic than I though.  The descriptor
> doesn't contain the address of the data buffer. Instead, the
> descriptor is to be followed by the data buffer immediately. It's
> not only the driver invention :-(

I'm happy we can now see now why nobody has "fixed" this for more than
15 years :-)

I think going down the road of trying to use the flexible mode is a
dead end.  I doubt any other OS driver is using it, and that means
that there are likely many other errata hiding in the bushes which you
will unearth by trying to use this new descriptor mode.  And it won't
show up when you test it, it will show up when some random person in
some remote data center somewhere updates their kernel, and they won't
send us a bug report, they'll replace their card or downgrade their
kernel instead.

And that's why it's inappropiate to approach this problem in this way
for a driver this old, and for hardware that's been around so long.

Just make the driver use consistent buffers for RX, and when packets
arrive an SKB is allocated and the packet data is copied into the SKB
from the consistent buffer.

And for 2.6.31-rcX we probably have to simply revert your change.
