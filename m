From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] nf_conntrack: avoid kernel pointer value leak in slab name
Date: Sat, 14 May 2016 15:21:31 -0700
Message-ID: <CA+55aFwthSgQyG_=mTpwctpOWqc1D7KgWHrdrqh+PLiFjuT=_A@mail.gmail.com>
References: <alpine.LFD.2.20.1605141116100.24646@i7>
	<CA+55aFx_PuzNC0riLEN7PUpVnvQg374ZqCYBV-Uw6Be-OA=DwQ@mail.gmail.com>
	<20160514213322.GD9763@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Network Development List <netdev@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f195.google.com ([209.85.213.195]:34669 "EHLO
	mail-ig0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753810AbcENWVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 18:21:32 -0400
Received: by mail-ig0-f195.google.com with SMTP id kj7so4162981igb.1
        for <netdev@vger.kernel.org>; Sat, 14 May 2016 15:21:31 -0700 (PDT)
In-Reply-To: <20160514213322.GD9763@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 14, 2016 at 2:33 PM, Willy Tarreau <w@1wt.eu> wrote:
>
> Why simply not cast the atomic to (unsigned long long) instead of (u64)
> so that %llu always matches ?

Yes, that fixes the problem. It's just more typing, and annoying. The
fact that MS got it right while posix and gcc screwed it up is a bit
embarrassing..

If we ever start using __uint128_t, we'll have even more problems in
this area. Oh well.

                Linus
