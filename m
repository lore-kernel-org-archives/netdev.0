From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Wed, 22 Aug 2012 14:26:49 +0100
Message-ID: <1345642009.15245.0.camel@deadeye.wl.decadent.org.uk>
References: <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com>
	 <503437D4.8090706@zytor.com>
	 <1345601051.2659.93.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120821.193446.1534561579811962053.davem@davemloft.net>
	 <503450E2.2040504@zytor.com>
	 <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	David Miller <davem@davemloft.net>, <tglx@linutronix.de>,
	<mingo@redhat.com>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>, <x86@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:41192 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932538Ab2HVN1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 09:27:05 -0400
In-Reply-To: <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-21 at 20:52 -0700, Linus Torvalds wrote:
[...]
> I haven't seen the patch being discussed, or the rationale for it. But
> I doubt it makes sense to do 128-bit MMIO and expect any kind of
> atomicity things anyway, and I very much doubt that using SSE would
> make all that much sense. What's the background, and why would you
> want to do this crap?

It's <1345598804.2659.78.camel@bwh-desktop.uk.solarflarecom.com>.
When updating a TX DMA ring pointer in sfc, we can push the first new
descriptor at the same time, so that for a linear packet only one DMA
read is then required before the packet goes out on the wire.  Currently
this requires 2-4 MMIO writes (each a separate PCIe transactions),
depending on the host word size.  There is a measurable reduction in
latency if we can reduce it to 1 PCIe transaction.  (But as previously
discussed, write-combining isn't suitable for this.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
