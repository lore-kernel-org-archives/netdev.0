From: Ronny Meeus <ronny.meeus@gmail.com>
Subject: Re: Question: How to configure the Ethernet receive buffer allocation
 (was: (no subject)).
Date: Sat, 13 Oct 2012 13:18:00 +0200
Message-ID: <CAMJ=MEfb5ELpJKDLYBUQ25ACmPosN7ut8zqTAojNCi8Kcm7-AQ@mail.gmail.com>
References: <CAMJ=MEd89zzLhxt7FYOVCbh5OzW+8jAsx38uV53zCodXvVtfMQ@mail.gmail.com>
 <1350118698.21172.13737.camel@edumazet-glaptop> <CAMJ=MEcqAsg6tsy9ALzcGqXmL9fQ2cmW6xXxup40iB2MrfuT8g@mail.gmail.com>
 <CAMJ=MEdu9EtYhYHFyXD04b7M4BseX6oDfmB=NB9CAfMo59pxow@mail.gmail.com> <1350124173.21172.14017.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:48659 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956Ab2JMLSV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Oct 2012 07:18:21 -0400
Received: by mail-ob0-f174.google.com with SMTP id uo13so3611514obb.19
        for <netdev@vger.kernel.org>; Sat, 13 Oct 2012 04:18:21 -0700 (PDT)
In-Reply-To: <1350124173.21172.14017.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 13, 2012 at 12:29 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sat, 2012-10-13 at 12:14 +0200, Ronny Meeus wrote:
>
>> The ideal solution would be to have a solution were we use a packet
>> ring to store the packets in but use a standard socket to receive the
>> packets from this ring. In this way we can combine the ideal memory
>> usage of the packet ring solution (in fact almost no overhead)
>> combined with the virtual memory that must not be wasted in the
>> application space.
>>
>> I have no clue whether this is possible ...
>
> But how do you know before receiving packet from network that its size
> will be 1000 instead of 1500 ?
>
> Packet ring is nice when you have the right size, or else you need to
> add a copy of packets. Or you dedicate an ethernet device for an
> application (direct delivery to user land, no skbs at all)

This is in fact the case. This is a dedicated interface and the
packets will not be bigger than 1000 bytes.

>
> 2.6.32 kernel is a bit old for us on netdev.
>
> If you try latest kernel (Linus tree), you'll discover we no longer use
> one kmalloc-4096 entry to store a packet.
>
> However, with MTU=1500, we still consume around 2048 bytes per packet
> (including overhead)
>
> If you really cant change packet size and stay at 1000, you could try :
> reducing device mtu, to lower wasted ram per packet
>

In the mean time I use 64K pages for the kernel and then I see that 2K
buffers are getting used, so I gained already a large amount of
memory.
By reducing the MTU to 1000, it consumes buffers of 2048bytes.

Still not clear to me whether it is possible to combine the packet
ring only in kernel space and receive packets from it using a normal
socket operation?
