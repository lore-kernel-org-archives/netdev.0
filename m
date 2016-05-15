From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] nf_conntrack: avoid kernel pointer value leak in slab name
Date: Sun, 15 May 2016 11:05:16 -0700
Message-ID: <CA+55aFxRg36qT9HSY9QgCV-8hhxD83Pa_kVyP=G+pa3iYBxj8g@mail.gmail.com>
References: <alpine.LFD.2.20.1605141116100.24646@i7>
	<CA+55aFx_PuzNC0riLEN7PUpVnvQg374ZqCYBV-Uw6Be-OA=DwQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Willy Tarreau <w@1wt.eu>,
	Network Development List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:34702 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908AbcEOSFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 14:05:17 -0400
Received: by mail-io0-f182.google.com with SMTP id 190so187041273iow.1
        for <netdev@vger.kernel.org>; Sun, 15 May 2016 11:05:17 -0700 (PDT)
In-Reply-To: <CA+55aFx_PuzNC0riLEN7PUpVnvQg374ZqCYBV-Uw6Be-OA=DwQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 14, 2016 at 2:31 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> "u64" is indeed "unsigned long long" on x86 and many other
> architectures, but on alpha and ia64 it's just "unsigned long".

Actually, I take that back.

In the kernel, it seems to always be "unsigned long long", even on
alpha and ia64.

We do have a "int-l64.h" file that typedef's __u64 to be just unsigned
long, and yes, that file is included for alpha and ia64, but it seems
that that only happens when __KERNEL__ is not defined.

So it does seem like using "%ull" and u64 is fine. Not in general, but
inside the kernel it's ok.

              Linus
