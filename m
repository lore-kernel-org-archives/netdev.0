From: David Miller <davem@davemloft.net>
Subject: Re: adding tcpdump/OAM support to usb ATM devices
Date: Sun, 27 Apr 2008 14:35:04 -0700 (PDT)
Message-ID: <20080427.143504.197027637.davem@davemloft.net>
References: <1209331913.8768.214.camel@ragnarok>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jerj@coplanar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44747
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751058AbYD0VfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 17:35:04 -0400
In-Reply-To: <1209331913.8768.214.camel@ragnarok>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeremy Jackson <jerj@coplanar.net>
Date: Sun, 27 Apr 2008 17:31:53 -0400

> The question: what is the recommended way to push the captured cells to
> userspace?  raw ATM socket, netlink, packet socket, i'm not up to speed
> here people!
> 
> in 2.6.22 drivers/usb/atm/usbatm.c::usbatm_extract_one_cell()

It depends upon what you want to do with this.

Maybe it makes sense, if what you're trying to do is expose the
signalling layer of the packet to diagnostic tools, is have an
option in the driver such that the entire ATM header area will
be presented to the AF_PACKET socket when tapping the network.

Could that work?

Adding special mechanisms to get at the packet data is going to
make it more difficult to use this stuff, and kind of defeat
your purpose.  So anything that's automatically working with
tcpdump and will "just work" is preferred.
