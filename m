From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Wed, 22 Aug 2012 10:54:41 -0700
Message-ID: <CA+55aFzcqhHU_+uR33=q+49jK97e=EofFF7g7Z0K1RU_PGwMTw@mail.gmail.com>
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
 <CA+55aFxMD-Jn3fPgum7a+3EhNiWB-Mjv+1yamR7ELHwroA_+7Q@mail.gmail.com>
 <1345655343.2709.56.camel@bwh-desktop.uk.solarflarecom.com>
 <50351304.20608@zytor.com> <1345656446.2709.65.camel@bwh-desktop.uk.solarflarecom.com>
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
Received: from mail-ob0-f174.google.com ([209.85.214.174]:58923 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755429Ab2HVRzC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 13:55:02 -0400
Received: by obbuo13 with SMTP id uo13so1707308obb.19
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 10:55:01 -0700 (PDT)
In-Reply-To: <1345656446.2709.65.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 22, 2012 at 10:27 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
>
> If this is right, how can it be safe to use readq/writeq at all?

Pray.

Or don't care about ordering: use hardware that is well-designed and
doesn't have crap interfaces that are fragile.

If you care about ordering, you need to do them as two separate
accesses, and have a fence in between. Which, quite frankly, sounds
like the right model for you *anyway*, since then you could use
write-combining memory and you might even go faster, despite an
explicit fence and thus a minimum of 2 transactions.

Seriously. If you care that deeply about the ordering of the bytes you
write out, MAKE THAT ORDERING VERY EXPLICIT IN THE SOURCE CODE. Don't
say "oh, with this hack, I win 100ns". You need to ask yourself: what
do you care about more? Going really fast on some machine that you can
test, or being safe?

With PCIe, it's *probably* fine to just say "we expect 64-bit accesses
to make it through unmolested".

The 128-bit case I really don't know about. It probably works too. But
while I'd call the 64-bit case almost certain (in the absence of truly
crap hardware), the 128-bit case I have a hard time judging how
certain it is going to be.

                   Linus
