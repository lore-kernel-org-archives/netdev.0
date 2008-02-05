From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/2] tun: impossible to deassert IFF_ONE_QUEUE or
 IFF_NO_PI
Date: Tue, 05 Feb 2008 03:05:47 -0800 (PST)
Message-ID: <20080205.030547.156453415.davem@davemloft.net>
References: <200802050745.m157j2vh010306@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nwfilardo@gmail.com, jeff@garzik.org,
	maxk@qualcomm.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46082
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756676AbYBELFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 06:05:20 -0500
In-Reply-To: <200802050745.m157j2vh010306@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Mon, 04 Feb 2008 23:45:21 -0800

> From: "Nathaniel Filardo" <nwfilardo@gmail.com>
> 
> Taken from http://bugzilla.kernel.org/show_bug.cgi?id=9806
> 
> The TUN/TAP driver only permits one-way transitions of IFF_NO_PI or
> IFF_ONE_QUEUE during the lifetime of a tap/tun interface.  Note that
> tun_set_iff contains
> 
>  541         if (ifr->ifr_flags & IFF_NO_PI)
>  542                 tun->flags |= TUN_NO_PI;
>  543 
>  544         if (ifr->ifr_flags & IFF_ONE_QUEUE)
>  545                 tun->flags |= TUN_ONE_QUEUE;
> 
> This is easily fixed by adding else branches which clear these bits.
> 
> Steps to reproduce:
> 
> This is easily reproduced by setting an interface persistant using tunctl then
> attempting to open it as IFF_TAP or IFF_TUN, without asserting the IFF_NO_PI
> flag.  The ioctl() will succeed and the ifr.flags word is not modified, but the
> interface remains in IFF_NO_PI mode (as it was set by tunctl).
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Jeff Garzik <jeff@garzik.org>
> Acked-by: Maxim Krasnyansky <maxk@qualcomm.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
