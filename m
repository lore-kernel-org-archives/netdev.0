From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect for
 sockets in accept(3)
Date: Sat, 31 Oct 2015 12:54:50 -0700
Message-ID: <CA+55aFxeiVx4wMhWALfU3KYCqhsnr8T8M-dEZc3aAyzobWeRGQ@mail.gmail.com>
References: <20151029001532.GE22011@ZenIV.linux.org.uk>
	<1446089381.7476.114.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151029041611.GF22011@ZenIV.linux.org.uk>
	<1446122119.7476.138.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+55aFx_BQG4FzSuyL2KAz=c+R0cPv0ZpjboT_=yKjZNGmTUEg@mail.gmail.com>
	<20151030210215.GI22011@ZenIV.linux.org.uk>
	<CA+55aFyoA5sXQvFDavNa7cGkRevunmtPe8F8-_tZ9-826qfkgw@mail.gmail.com>
	<CA+55aFy9fPmbSCJoQiCkjkaiU2HTM6p=o-pJgiV7asyVWBjAEg@mail.gmail.com>
	<20151030223317.GK22011@ZenIV.linux.org.uk>
	<CA+55aFwfFb=LXU77AbiPDHgWcpBwTBoJB4EMCZgTgX32cxMYWw@mail.gmail.com>
	<20151031193449.GM22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Network Development <netdev@vger.kernel.org>,
	David Howells <dhowells@redhat.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:33318 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887AbbJaTyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Oct 2015 15:54:50 -0400
In-Reply-To: <20151031193449.GM22011@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 31, 2015 at 12:34 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>
> ... and here's the current variant of mine.

Ugh. I really liked how simple mine ended up being. Yours is definitely not.

And based on the profiles from Eric, finding the fd is no longer the
problem even with my simpler patch. The problem ends up being the
contention on the file_lock spinlock.

Eric, I assume that's not "expand_fdtable", since your test-program
seems to expand the fd array at the beginning. So it's presumably all
from the __alloc_fd() use, but we should double-check.. Eric, can you
do a callgraph profile and see which caller is the hottest?

                 Linus
