From: Jeremy Jackson <jerj@coplanar.net>
Subject: Re: adding tcpdump/OAM support to usb ATM devices
Date: Sun, 27 Apr 2008 18:35:14 -0400
Message-ID: <1209335714.8768.226.camel@ragnarok>
References: <1209331913.8768.214.camel@ragnarok>
	 <20080427.143504.197027637.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from titan.coplanar.net ([70.47.139.2]:48524 "EHLO
	titan.coplanar.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447AbYD0WfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 18:35:14 -0400
In-Reply-To: <20080427.143504.197027637.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sun, 2008-04-27 at 14:35 -0700, David Miller wrote:
> From: Jeremy Jackson <jerj@coplanar.net>
> Date: Sun, 27 Apr 2008 17:31:53 -0400
> 
> > The question: what is the recommended way to push the captured cells to
> > userspace?  raw ATM socket, netlink, packet socket, i'm not up to speed
> > here people!
> > 
> > in 2.6.22 drivers/usb/atm/usbatm.c::usbatm_extract_one_cell()
> 
> It depends upon what you want to do with this.
> 
> Maybe it makes sense, if what you're trying to do is expose the
> signalling layer of the packet to diagnostic tools, is have an
> option in the driver such that the entire ATM header area will
> be presented to the AF_PACKET socket when tapping the network.
> 
> Could that work?
> 
> Adding special mechanisms to get at the packet data is going to
> make it more difficult to use this stuff, and kind of defeat
> your purpose.  So anything that's automatically working with
> tcpdump and will "just work" is preferred.

Backgroud: OAM cells are like the ICMP of ATM networking, they are
separate from payload cells, not part of the headers.  They do share the
VPI/VCI of the data circuit, but have a different cell Packet Type
Indication (PTI)

With br2684, it exposes an ethernet-like device.  Tcpdump can work on
that no problem, and perhaps it could expose the headers of the
first/last cell of each "frame", but I don't see how the OAM cells would
fit into capturing packets that way.

Or can an AF_PACKET socket be made that retrieved raw ATM cells (AAL0
style) regardless of the upper layer (br2684)?

Sadly, my goal isn't an overhaul of the ATM stack, but a
minimal-distance hack with some good advice thrown in.  The typical
tcpdump would grab all cells, or perhaps unclaimed ones unless in
promisc mode, but I'm happy with just partial capture of certain out of
band cells for now.

Maybe the code in usbatm_extract_one_cell() that drops cells, would
check for an ATM packet socket first, and dump the cells in there,
otherwise drop them.

-- 
Jeremy Jackson
Coplanar Networks
(519)489-4903
http://www.coplanar.net
jerj@coplanar.net

