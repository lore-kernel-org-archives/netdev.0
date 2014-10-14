From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: Netlink mmap tx security?
Date: Tue, 14 Oct 2014 15:16:46 -0700
Message-ID: <CALCETrWDSG2EhxBnM8Jm55Ov8PYQ_w3Wf88SKYOB1q1WgRpbEw@mail.gmail.com>
References: <CALCETrWfQe5H2Ht7cjCQLfUw+XUcRvga_H93esaWpAp37=noZg@mail.gmail.com>
 <20141014.151949.1967601568480255495.davem@davemloft.net> <CALCETrUYBed_TBacxoDPMphM5y=iqxho2isrDruOQi=pmK2yoQ@mail.gmail.com>
 <20141014.160056.2113064815910782529.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>,
	Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:35749 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754621AbaJNWRI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 18:17:08 -0400
Received: by mail-la0-f52.google.com with SMTP id hz20so13643lab.39
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2014 15:17:06 -0700 (PDT)
In-Reply-To: <20141014.160056.2113064815910782529.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 14, 2014 at 1:00 PM, David Miller <davem@davemloft.net> wrote:
> From: Andy Lutomirski <luto@amacapital.net>
> Date: Tue, 14 Oct 2014 12:33:43 -0700
>
>> For full honesty, there is now the machinery developed for memfd
>> sealing, but I can't imagine that this is ever faster than just
>> copying the buffer.
>
> I don't have much motivation to even check if it's a worthwhile
> pursuit at this point.
>
> Someone who wants to can :-)
>
>> I think that the NETLINK_SKB_TX declaration in include/linux/netlink.h
>> should probably go, too.  And there's the last parameter to
>> netlink_set_ring, too, and possibly even the nlk->tx_ring struct
>> itself.
>
> Agreed on all counts, here is the new patch:
>
> ====================
> [PATCH] netlink: Remove TX mmap support.
>
> There is no reasonable manner in which to absolutely make sure that another
> thread of control cannot write to the pages in the mmap()'d area and thus
> make sure that netlink messages do not change underneath us after we've
> performed verifications.
>
> Reported-by: Andy Lutomirski <luto@amacapital.net>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Looks sensible to me, but I have no idea how to test it.

It's at least remotely possible that there's something that assumes
that assumes that the availability of NETLINK_RX_RING implies
NETLINK_TX_RING, which would be unfortunate.

--Andy
