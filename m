From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Wed, 22 Aug 2012 11:18:13 -0700
Message-ID: <50352265.3050203@zytor.com>
References: <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com>  <1345642009.15245.0.camel@deadeye.wl.decadent.org.uk>  <CA+55aFzxhxjOeFSUUJ6XQGUmnaZf7QPSz611zmj2VziEDUB_sA@mail.gmail.com>  <1345645499.15245.8.camel@deadeye.wl.decadent.org.uk>  <20120822143054.GD9803@kvack.org>  <1345647537.2709.0.camel@bwh-desktop.uk.solarflarecom.com>  <5034F725.2090802@zytor.com>  <AE90C24D6B3A694183C094C60CF0A2F6026B6FC1@saturn3.aculab.com>  <1345650689.2709.32.camel@bwh-desktop.uk.solarflarecom.com>  <50350098.6030100@zytor.com>  <1345653844.2709.51.camel@bwh-desktop.uk.solarflarecom.com>  <CA+55aFxMD-Jn3fPgum7a+3EhNiWB-Mjv+1yamR7ELHwroA_+7Q@mail.gmail.com>  <1345655343.2709.56.camel@bwh-desktop.uk.solarflarecom.com>  <50351304.20608@zytor.com>  <1345656446.2709.65.camel@bwh-desktop.uk.solarfl
 arecom.com>  <CA+55aFzcqhHU_+uR33=q+49jK97e=EofFF7g7Z0K1RU_PGwMTw@mail.gmail.com> <1345659074.2709.80.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Laight <David.Laight@aculab.com>,
	Benjamin LaHaise <bcrl@kvack.org>,
	David Miller <davem@davemloft.net>, tglx@linutronix.de,
	mingo@redhat.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, x86@kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:44938 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933100Ab2HVSSj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2012 14:18:39 -0400
In-Reply-To: <1345659074.2709.80.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/22/2012 11:11 AM, Ben Hutchings wrote:
> 
> Well the whole point of having the two 32-bit generic implementations is
> that hardware may care about the order!  How can it be right that a
> 64-bit implementation assumes it doesn't?
> 

On x86 platforms it is pretty much universal (as in: I have never seen
an exception) that transactions that are broken up are broken up in
littleendian order.  That was the original readq/writeq implementation
on x86-32, but it screwed up some other architectures.

The other reason to not have readq/writeq by default where we *know* it
can't be supported is that some drivers (e.g. the CNIC/OPA-2 driver I
mentioned) can do better, performance-wise, if it knows that.

	-hpa
