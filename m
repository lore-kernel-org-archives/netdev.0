From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Wed, 22 Aug 2012 09:51:10 -0700
Message-ID: <CA+55aFwTyT8v9r7jW2=jp29_yMMacWjMwCka+_YktOOMzBHWBw@mail.gmail.com>
References: <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com>
 <503437D4.8090706@zytor.com> <1345601051.2659.93.camel@bwh-desktop.uk.solarflarecom.com>
 <20120821.193446.1534561579811962053.davem@davemloft.net> <503450E2.2040504@zytor.com>
 <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com>
 <1345642009.15245.0.camel@deadeye.wl.decadent.org.uk> <CA+55aFzxhxjOeFSUUJ6XQGUmnaZf7QPSz611zmj2VziEDUB_sA@mail.gmail.com>
 <1345645499.15245.8.camel@deadeye.wl.decadent.org.uk> <20120822143054.GD9803@kvack.org>
 <1345647537.2709.0.camel@bwh-desktop.uk.solarflarecom.com>
 <5034F725.2090802@zytor.com> <AE90C24D6B3A694183C094C60CF0A2F6026B6FC1@saturn3.aculab.com>
 <1345650689.2709.32.camel@bwh-desktop.uk.solarflarecom.com> <50350098.6030100@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Laight <David.Laight@aculab.com>,
	Benjamin LaHaise <bcrl@kvack.org>,
	David Miller <davem@davemloft.net>, tglx@linutronix.de,
	mingo@redhat.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, x86@kernel.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:58626 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754084Ab2HVQvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 12:51:31 -0400
Received: by wgbdr13 with SMTP id dr13so1042261wgb.1
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 09:51:30 -0700 (PDT)
In-Reply-To: <50350098.6030100@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 22, 2012 at 8:54 AM, H. Peter Anvin <hpa@zytor.com> wrote:
>
> Sorry, you fail.  There are definitely systems in the field where readq()
> and writeq() are implemented, because the CPU supports them, where the
> fabric does not guarantee they are intact.

Indeed.

It's unlikely to be an issue with a PCIe driver, though. I'm pretty
sure you can rely on 64-bit transfers there, especially with a CPU
that is modern enough to run 64-bit mode.

That said, even with PCIe, I wonder if older CPU's (think Intel with a
front-side bus, rather than PCIe on die) necessarily always do 128-bit
writes. The FSB is just 64 bits wide, and I could *imagine* that a
PCIe chipset behind the FSB might end up just always generating at
most 64-bit PCIe transactions for host accesses just because that
would be "natural".

Sounds unlikely, but hey, hardware sometimes does odd things.

             Linus
