From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Wed, 22 Aug 2012 11:28:20 -0700
Message-ID: <CA+55aFyBVRHk6ZcWxEPoUPRmFYyW6yihbi26vS-SAKey0nv9yA@mail.gmail.com>
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
 <CA+55aFzcqhHU_+uR33=q+49jK97e=EofFF7g7Z0K1RU_PGwMTw@mail.gmail.com> <1345659074.2709.80.camel@bwh-desktop.uk.solarflarecom.com>
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
Received: from mail-ob0-f174.google.com ([209.85.214.174]:43413 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964941Ab2HVS2m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 14:28:42 -0400
Received: by obbuo13 with SMTP id uo13so1746007obb.19
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 11:28:41 -0700 (PDT)
In-Reply-To: <1345659074.2709.80.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 22, 2012 at 11:11 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
>
> Right, I think it's been made pretty clear that it's going to be
> dependent on more than just architecture.

Well, it's entirely possible that the 128-bit case will work correctly
on all x86-64 hardware out there on PCIe.

I just can't guarantee it, because we certainly have had issues with
hw doing odd things before. But maybe PCIe really is well-specified
enough, and maybe nobody has done a odd PCIe bridges, and maybe every
time some 128-bit access is split, the bus in question still always
remembers the original 128-bit size in the transaction. It's not at
all impossible. I just wouldn't *guarantee* it.

And to some degree, for high-end server-only hardware in particular,
it really *is* acceptable to say "If you have odd hardware, odd things
will happen". So for this particular driver, maybe the right approach
is simply to say "we require that your fabric works right". And see if
anybody ever complains.

The 100ns may be worth those kinds of "you'd better not have old/crap
hardware" decisions. It's not acceptable for some drivers (a driver
for some consumer ATA chip might not want to make that kind of choice,
and say "whatever, we'll be really conservative), but "Quod licet
Jovi, non licet bovi".

The fact that something might not be *guaranteed* to always work
doesn't necessarily mean that it is always the wrong thing to do..

              Linus
