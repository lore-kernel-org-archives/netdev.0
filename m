From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Tue, 21 Aug 2012 21:42:20 -0700
Message-ID: <CA+55aFxmHb6J6Qfaj8Jq2gRqmCb-eNZNK2-KUrFstRWuuKPV9A@mail.gmail.com>
References: <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com>
 <503437D4.8090706@zytor.com> <1345601051.2659.93.camel@bwh-desktop.uk.solarflarecom.com>
 <20120821.193446.1534561579811962053.davem@davemloft.net> <503450E2.2040504@zytor.com>
 <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	tglx@linutronix.de, mingo@redhat.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, x86@kernel.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:48972 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511Ab2HVEmm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 00:42:42 -0400
Received: by weyx8 with SMTP id x8so334556wey.19
        for <netdev@vger.kernel.org>; Tue, 21 Aug 2012 21:42:41 -0700 (PDT)
In-Reply-To: <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 21, 2012 at 8:52 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> I haven't seen the patch being discussed, or the rationale for it. But
> I doubt it makes sense to do 128-bit MMIO and expect any kind of
> atomicity things anyway, and I very much doubt that using SSE would
> make all that much sense. What's the background, and why would you
> want to do this crap?

Btw, for the 64-bit case, we did have ordering issues, and maybe some
128-bit model has similar ordering issues. Fine. You can't rely on
128-bit atomic accesses anyway on 99% of all hardware - either the CPU
itself cannot do it, or it's too damn inconvenient with XMM only
registers, or the bus itself is limited to 64 bits at a time anyway,
so the CPU or the IO interface would split such an access *anyway*.

So the whole concept of "we rely on atomic 128-bit MMIO accesses"
seems terminally broken. Any driver that thinks it needs that is just
crazy.

And those issues have nothing to do with x86 kernel_fpu_begin/end()
what-so-ever.

So judging by that, I would say that some driver writer needs to take
a few pills, clear up their head, and take another look at their life.
Tell them to look at

    include/asm-generic/io-64-nonatomic-hi-lo.h

(and *-lo-hi.h) instead, and ponder the wisdom of just doing it that
way. Tell them to go f*ck themselves if they think they need XMM
registers. They are wrong, for one reason or another.

                 Linus
