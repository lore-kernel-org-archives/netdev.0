From: David Miller <davem@davemloft.net>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Wed, 30 Jul 2008 16:56:21 -0700 (PDT)
Message-ID: <20080730.165621.211366535.davem@davemloft.net>
References: <20080730235004.GC21999@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akarkare@marvell.com, nico@cam.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42751
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752146AbYG3X4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 19:56:21 -0400
In-Reply-To: <20080730235004.GC21999@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Thu, 31 Jul 2008 01:50:04 +0200

Thanks for all the great data and testing.

> Given this, I'm wondering about the following:
> 
> 1. Considering the drop in CPU utilisation, are there reasons not
>    to use software GSO on non-hardware-GSO-capable netdevices (apart
>    from GSO possibly confusing tcpdump/iptables/qdiscs/etc)?

We should probably enable software GSO whenever the device can
do scatter-gather and checksum offload.

> 2. Why is the number of cycles necessary to send 1 GiB of data so
>    much higher (~3.5x higher) in 1000 Mb/s mode than in 100 Mb/s mode?
>    (Is this maybe just because time(1) is inaccurate w.r.t. time spent
>    in interrupts and such?)

This I have no idea about.

> 3. Why does dev_hard_start_xmit() get sent 64 KiB segments when the
>    link is in 100 Mb/s mode but gso_segs never grows beyond 3 when
>    the link is in 1000 Mb/s mode?

Because the link can empty the socket send buffer fast enough such
that there is often not enough data to coalesce into larger GSO frames.
At least that's my guess.
