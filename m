From: David Miller <davem@davemloft.net>
Subject: Re: Debounce code vs. dma_sync_single_range_for_cpu() and e100
 driver.
Date: Tue, 14 Jul 2009 12:38:48 -0700 (PDT)
Message-ID: <20090714.123848.189674670.davem@davemloft.net>
References: <m31vokbi6p.fsf@intrepid.localdomain>
	<20090713181237.GD31979@n2100.arm.linux.org.uk>
	<m3d483m53q.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46465
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751332AbZGNTio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2009 15:38:44 -0400
In-Reply-To: <m3d483m53q.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Tue, 14 Jul 2009 21:34:01 +0200

> Well, e100 driver uses streaming mapping for it's RX/TX buffers as well
> as for the descriptors. Now it gets tricky - RX ring descriptors can be
> written by the device at any time (when completing RX) and at the same
> time the CPU has to be able to check the descriptor's status. It seems
> it can't be formally done with the streaming DMA API, since it doesn't
> provide invalidate and flush operations, it's rather about transfering
> control.
> 
> I guess the coherent/consistent allocations should be used for this
> purpose (= uncached RAM pages on IXP4xx if I understand it correctly).
> 
> Now that I know the inner working of DMA API the attached patch "fixes"
> the e100 problems, but it still doesn't seem to be a valid use of the
> API.

E100's use of streaming mappings for RX descriptors is a bug, it
should be using consistent mappings for sure.

And it's especially buggy if it isn't doing DMA API sync calls before
looking at descriptor fields, as your patch seems to cure.
