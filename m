From: "Phoebe Buckheister" <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: Re: [PATCH net-next v4 1/4] ieee802154: add
 generic header handling routines
Date: Wed, 5 Mar 2014 02:01:52 +0100
Message-ID: <0049a78200f573d8acc64aa879d4412c.squirrel@webmail.itwm.fhg.de>
References: <cc9ba7943aebff9ba87b60778b62f1a8.squirrel@webmail.itwm.fhg.de>
	<20140304.172025.2034977449200344617.davem@davemloft.net>
	<a23fcc368f1421286c1115c2365942ce.squirrel@webmail.itwm.fhg.de>
	<20140304.192309.337489223683931299.davem@davemloft.net>
Reply-To: phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20140304.192309.337489223683931299.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

> SUre it would, store the addresses in your internal data structures
> as a __be64 too.  That's what IPV4/IPV6 do, we store addresses and
> ports in the socket in network byte order.  Comparisons just work.

That's the thing - there are so many different byte orders floating around
at the moment. Network byte order is little endian. Hardware addresses are
big endian in the network layer and 6lowpan though, and our sockaddrs are
host byte order for some parts and big endian for others. It's a real
mess. The solution in my patch seemed the cleanest option to me.

Storing *everything* in network byte order would require a small adaption
layer at every interaction with userspace to fix byte ordering, but that's
doable. 6lowpan would have to do an extra byteswap for the address that I
currently do in the header ops.

I'll change everything that might come in contact with the network to __le
variants and add explicit swaps where required.


------------------------------------------------------------------------------
Subversion Kills Productivity. Get off Subversion & Make the Move to Perforce.
With Perforce, you get hassle-free workflows. Merge that actually works. 
Faster operations. Version large binaries.  Built-in WAN optimization and the
freedom to use Git, Perforce or both. Make the move to Perforce.
http://pubads.g.doubleclick.net/gampad/clk?id=122218951&iu=/4140/ostg.clktrk
