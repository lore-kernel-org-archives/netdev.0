From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Wed, 22 Aug 2012 09:55:05 -0700
Message-ID: <CA+55aFxMD-Jn3fPgum7a+3EhNiWB-Mjv+1yamR7ELHwroA_+7Q@mail.gmail.com>
References: <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com>
 <503437D4.8090706@zytor.com> <1345601051.2659.93.camel@bwh-desktop.uk.solarflarecom.com>
 <20120821.193446.1534561579811962053.davem@davemloft.net> <503450E2.2040504@zytor.com>
 <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com>
 <1345642009.15245.0.camel@deadeye.wl.decadent.org.uk> <CA+55aFzxhxjOeFSUUJ6XQGUmnaZf7QPSz611zmj2VziEDUB_sA@mail.gmail.com>
 <1345645499.15245.8.camel@deadeye.wl.decadent.org.uk> <20120822143054.GD9803@kvack.org>
 <1345647537.2709.0.camel@bwh-desktop.uk.solarflarecom.com>
 <5034F725.2090802@zytor.com> <AE90C24D6B3A694183C094C60CF0A2F6026B6FC1@saturn3.aculab.com>
 <1345650689.2709.32.camel@bwh-desktop.uk.solarflarecom.com>
 <50350098.6030100@zytor.com> <1345653844.2709.51.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	David Laight <David.Laight@aculab.com>,
	Benjamin LaHaise <bcrl@kvack.org>,
	David Miller <davem@davemloft.net>, tglx@linutronix.de,
	mingo@redhat.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, x86@kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:39553 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932992Ab2HVQz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 12:55:27 -0400
Received: by wicr5 with SMTP id r5so5911252wic.1
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 09:55:26 -0700 (PDT)
In-Reply-To: <1345653844.2709.51.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 22, 2012 at 9:44 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
>
> Well, when the issue of 64-bit MMIO was discussed earlier this year, you
> said nothing about this.  I thought the conclusion was that any
> definitions provided by <asm/io.h> *must* be atomic and drivers can use
> <asm-generic/io-64-nonatomic-hi-lo.h> or
> <asm-generic/io-64-nonatomic-lo-hi.h> as a fallback.

Think 32-bit PCI with a 64-bit CPU.

The CPU itself does the 64-bit access no problem. The bus? Not so
much. Even if it's a burst transaction with a single packet, the
actual device on the other side will see the 64-bit value as two
separate parts. Sometimes that matters, sometimes it doesn't (ask
yourself: "What's the atomicity guarantee at the device end? Burst
transaction or individual word of a transaction?").

Again, being limited to PCIe, you are unlikely to hit these issues,
but system bridges can do odd things sometimes, and in the *general*
case it's definitely true that "writeq()" can generate multiple
accesses at the device end even if the *CPU* only generated a single
one.

            Linus
