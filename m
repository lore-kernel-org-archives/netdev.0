From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix struct sock bitfield annotation
Date: Fri, 09 Oct 2009 00:54:08 -0700 (PDT)
Message-ID: <20091009.005408.151610125.davem@davemloft.net>
References: <4ACE023D.9030208@gmail.com>
	<19f34abd0910081454v51455ee0p30ad6715b5ee31c0@mail.gmail.com>
	<4ACE8CEC.3020905@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vegard.nossum@gmail.com, netdev@vger.kernel.org, mingo@elte.hu
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37240
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753402AbZJIHyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 03:54:12 -0400
In-Reply-To: <4ACE8CEC.3020905@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 09 Oct 2009 03:07:56 +0200

> Point is we should not lose 8 bytes with kmemcheck on or off.
> I believe kmemcheck macros are fine as they are.
> 
> When we have a structure with
> 
>         unsigned char           sk_shutdown : 2,
>                                 sk_no_check : 2,
>                                 sk_userlocks : 4;
>         unsigned char           sk_protocol;
>         unsigned short          sk_type;
> 
> Its pretty clear its *logically* a bitfield aggregation, or if you prefer :

I think from a practical standpoint, you are right.

But Vegard is right too, as we should be able to put the annotation
right next to the ":" statements.

So if you really want why don't you put the sk_protocol and
sk_type into the ":" block as you mentioned.

And then you can use Arnaldo's 'pahole' instead of the kludgy
offsetof() which doesn't work with bitfields :-)

I want the 8 bytes back just like you, but seperating the annotation
from the real C bitfields looks definitely wrong to me.
