From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Question: How to configure the Ethernet receive buffer
 allocation (was: (no subject)).
Date: Sat, 13 Oct 2012 12:29:33 +0200
Message-ID: <1350124173.21172.14017.camel@edumazet-glaptop>
References: <CAMJ=MEd89zzLhxt7FYOVCbh5OzW+8jAsx38uV53zCodXvVtfMQ@mail.gmail.com>
	 <1350118698.21172.13737.camel@edumazet-glaptop>
	 <CAMJ=MEcqAsg6tsy9ALzcGqXmL9fQ2cmW6xXxup40iB2MrfuT8g@mail.gmail.com>
	 <CAMJ=MEdu9EtYhYHFyXD04b7M4BseX6oDfmB=NB9CAfMo59pxow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ronny Meeus <ronny.meeus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:60921 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751810Ab2JMK3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Oct 2012 06:29:36 -0400
Received: by mail-wi0-f178.google.com with SMTP id hr7so387221wib.1
        for <netdev@vger.kernel.org>; Sat, 13 Oct 2012 03:29:35 -0700 (PDT)
In-Reply-To: <CAMJ=MEdu9EtYhYHFyXD04b7M4BseX6oDfmB=NB9CAfMo59pxow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-10-13 at 12:14 +0200, Ronny Meeus wrote:

> The ideal solution would be to have a solution were we use a packet
> ring to store the packets in but use a standard socket to receive the
> packets from this ring. In this way we can combine the ideal memory
> usage of the packet ring solution (in fact almost no overhead)
> combined with the virtual memory that must not be wasted in the
> application space.
> 
> I have no clue whether this is possible ...

But how do you know before receiving packet from network that its size
will be 1000 instead of 1500 ?

Packet ring is nice when you have the right size, or else you need to
add a copy of packets. Or you dedicate an ethernet device for an
application (direct delivery to user land, no skbs at all)

2.6.32 kernel is a bit old for us on netdev.

If you try latest kernel (Linus tree), you'll discover we no longer use
one kmalloc-4096 entry to store a packet.

However, with MTU=1500, we still consume around 2048 bytes per packet
(including overhead)

If you really cant change packet size and stay at 1000, you could try :
reducing device mtu, to lower wasted ram per packet
