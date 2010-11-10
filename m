From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 0/2] net: Changes in queue allocation and freeing
Date: Wed, 10 Nov 2010 08:27:54 -0800
Message-ID: <AANLkTi=5rxQ6mmnhR7=_dh5u08raaoLiYo=6Gzj9CbL5@mail.gmail.com>
References: <alpine.DEB.1.00.1011091240470.18565@pokey.mtv.corp.google.com>
	<1289385696.2860.147.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:35884 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756231Ab0KJQ16 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 11:27:58 -0500
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id oAAGRuud009734
	for <netdev@vger.kernel.org>; Wed, 10 Nov 2010 08:27:56 -0800
Received: from pwj2 (pwj2.prod.google.com [10.241.219.66])
	by wpaz17.hot.corp.google.com with ESMTP id oAAGRsMe025376
	for <netdev@vger.kernel.org>; Wed, 10 Nov 2010 08:27:55 -0800
Received: by pwj2 with SMTP id 2so181457pwj.17
        for <netdev@vger.kernel.org>; Wed, 10 Nov 2010 08:27:54 -0800 (PST)
In-Reply-To: <1289385696.2860.147.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 10, 2010 at 2:41 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mardi 09 novembre 2010 =E0 12:47 -0800, Tom Herbert a =E9crit :
>> Changes to both RX and TX queue allocation. =A0In both cases allocat=
e
>> in alloc_netdev_mq and free in free_netdev. =A0For RX the reference
>> couting also changed, the device reference count can now be used.
>
> Oh well :)
>
> Are they preliminary patches so that XPS also dont need the "referenc=
e
> counts specific to TX queues" ? ;)
>
Yes, this should allow the xps maps to be in the net_device also.
Sorry I neglected to mention that.

Also I noticed that the comment about RX queues refcnts is no longer
valid.  I can respin patch if necessary.

diff --git a/net/core/dev.c b/net/core/dev.c
index 87d89ba..34a42a8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5029,10 +5029,6 @@ static int netif_alloc_rx_queues(struct net_devi=
ce *dev)
        }
        dev->_rx =3D rx;

-       /*
-        * Set a pointer to first element in the array which holds the
-        * reference count.
-        */
        for (i =3D 0; i < count; i++)
                rx[i].dev =3D dev;
 #endif

>
>
>
