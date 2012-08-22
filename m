From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Wed, 22 Aug 2012 18:27:26 +0100
Message-ID: <1345656446.2709.65.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com>
	  <503437D4.8090706@zytor.com>
	  <1345601051.2659.93.camel@bwh-desktop.uk.solarflarecom.com>
	  <20120821.193446.1534561579811962053.davem@davemloft.net>
	  <503450E2.2040504@zytor.com>
	  <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com>
	  <1345642009.15245.0.camel@deadeye.wl.decadent.org.uk>
	  <CA+55aFzxhxjOeFSUUJ6XQGUmnaZf7QPSz611zmj2VziEDUB_sA@mail.gmail.com>
	  <1345645499.15245.8.camel@deadeye.wl.decadent.org.uk>
	  <20120822143054.GD9803@kvack.org>
	  <1345647537.2709.0.camel@bwh-desktop.uk.solarflarecom.com>
	  <5034F725.2090802@zytor.com>
	  <AE90C24D6B3A694183C094C60CF0A2F6026B6FC1@saturn3.aculab.com>
	  <1345650689.2709.32.camel@bwh-desktop.uk.solarflarecom.com>
	  <50350098.6030100@zytor.com>
	  <1345653844.2709.51.camel@bwh-desktop.uk.solarflarecom.com>
	  <CA+55aFxMD-Jn3fPgum7a+3EhNiWB-Mjv+1yamR7ELHwroA_+7Q@mail.gmail.com>
	 <1345655343.2709.56.camel@bwh-desktop.uk.solarflarecom.com>
	 <50351304.20608@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Laight <David.Laight@aculab.com>,
	Benjamin LaHaise <bcrl@kvack.org>,
	David Miller <davem@davemloft.net>, <tglx@linutronix.de>,
	<mingo@redhat.com>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>, <x86@kernel.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:32240 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S964824Ab2HVR1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 13:27:30 -0400
In-Reply-To: <50351304.20608@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-22 at 10:12 -0700, H. Peter Anvin wrote:
> On 08/22/2012 10:09 AM, Ben Hutchings wrote:
> >
> > Well, sure, I'm assuming that the driver is responsible for checking
> > that the device and its bus interface support an MMIO of the requested
> > width.
> >
> > But the architecture code must be responsible for reporting whether the
> > host supports it, right?
> >
> 
> No, the architecture code *can't*.

So, let me check that I understand this right:
- To support 32-bit architectures, a driver should include one of two
different definitions of readq/writeq depending on which order the
device needs to receive 32-bit operations.
- On 64-bit architectures (or at least x86_64), the system might split
up readq/writeq into 32-bit operations in unspecified order, and the
driver can't control this.

If this is right, how can it be safe to use readq/writeq at all?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
