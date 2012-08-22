From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Wed, 22 Aug 2012 14:28:50 -0700
Message-ID: <CA+55aFxxSFMiohu80BZCObA0APPe08h1-7eAZ_BLoAZDWqqv0Q@mail.gmail.com>
References: <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com>
 <5034591E.3040908@zytor.com> <20120821.211427.1832042852041589162.davem@davemloft.net>
 <20120822.141433.730254311852927123.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: hpa@zytor.com, bhutchings@solarflare.com, tglx@linutronix.de,
	mingo@redhat.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, x86@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:33223 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753933Ab2HVV3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 17:29:11 -0400
Received: by mail-ob0-f174.google.com with SMTP id uo13so113819obb.19
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 14:29:10 -0700 (PDT)
In-Reply-To: <20120822.141433.730254311852927123.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 22, 2012 at 2:14 PM, David Miller <davem@davemloft.net> wrote:
>
> BTW, just to clarify, I'm not saying that we should save the FPU on
> every trap where we find the FPU enabled or anything stupid like that.
>
> Definitely keep the kern_fpu_begin()/kern_fpu_end() type markers
> around FPU usage, but allow some kind of nesting facility.

So nesting shouldn't be horrible, but the thing that really screws
with people like the crypto use is not nesting, but the fact that
sometimes you can't save at all, and the whole "kernel_fpu_possible()"
or whatever we call the checking function.

IOW, in [soft]irq context, to avoid races with the irq happening as
the process is going to do something with the FPU state, we don't
allow saving and changing state, because that would mean that the
normal FP state paths would have to be irq-safe, and they aren't.

And once you have to have that fpu possible check, if it happens to
also disallow nested use, I doubt that's going to really affect
anybody. The code has to take the case of "I'm not allowed to change
FPU state" case into account regardless.

                 Linus
