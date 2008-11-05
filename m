From: Johann Baudy <johaahn@gmail.com>
Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Wed, 05 Nov 2008 16:16:39 +0100
Message-ID: <1225898199.5273.125.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Lovich, Vitali" <vlovich@qualcomm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Evgeniy Polyakov <zbr@ioremap.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g19.free.fr ([212.27.42.29]:55147 "EHLO smtp3-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750816AbYKEPQq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2008 10:16:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Patrick,


> The reason why its not in there is to avoid the unnecessary
> barrier when setting up the ring in packet_set_ring().

Is it a serious problem? packet_set_status() and packet_get_status()
will be called from multiple places and we will obtain a write/read
barrier at each call. I imagine that's more clean to insert those
barriers inside status functions even if we add only one useless flush
at the beginning. No?

>
> The code is fishy though, I agree. Have a look at this discussion:
>
> http://marc.info/?l=linux-netdev&m=119383985207984&w=2
>
My approach was to use the mechanism of RX_RING where the kernel is
allocating the buffer. In order to get something similar from kernel and
user point of view. Moving kernel buffer to user space could be studied
as global enhancement for RX_RING and TX_RING but that will need user
application changes.

I'm wondering if I also need to use flush_dcache_page() before getting
status buffer and attaching circular buffer pages to skb (both written
by user). 
According to this quote in [cachetlb.txt] of flush_dcache_page part:
	Any time the kernel writes to a page cache page, _OR_
	the kernel is about to read from a page cache page and
	user space shared/writable mappings of this page potentially
	exist, this routine is called.
 	...
	The phrase "kernel writes to a page cache page" means,
	...
	The corollary case is just as important, if there are users
	which have shared+writable mappings of this file, we must make
	sure that kernel reads of these pages will see the most recent
	stores done by the user. 

Can someone confirm?

Thanks in advance,
Johann










