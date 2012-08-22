From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Wed, 22 Aug 2012 08:13:41 -0700
Message-ID: <5034F725.2090802@zytor.com>
References: <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com>  <503437D4.8090706@zytor.com>  <1345601051.2659.93.camel@bwh-desktop.uk.solarflarecom.com>  <20120821.193446.1534561579811962053.davem@davemloft.net>  <503450E2.2040504@zytor.com>  <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com>  <1345642009.15245.0.camel@deadeye.wl.decadent.org.uk>  <CA+55aFzxhxjOeFSUUJ6XQGUmnaZf7QPSz611zmj2VziEDUB_sA@mail.gmail.com>  <1345645499.15245.8.camel@deadeye.wl.decadent.org.uk>  <20120822143054.GD9803@kvack.org> <1345647537.2709.0.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Benjamin LaHaise <bcrl@kvack.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>, tglx@linutronix.de,
	mingo@redhat.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, x86@kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:43159 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932736Ab2HVPN6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2012 11:13:58 -0400
In-Reply-To: <1345647537.2709.0.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/22/2012 07:58 AM, Ben Hutchings wrote:
>
> Because reordering, and see the comment at the top of this file.
>

Your architecture sounds similar to one I once worked on (Orion 
Microsystems CNIC/OPA-2).  That architecture had a descriptor ring in 
device memory, and a single trigger bit would move the head pointer.

We used write combining to write out a set of descriptors, and then used 
a non-write-combining write to do the final write which bumps the head 
pointer.  The UC write flushes the write combiners ahead of it, so it 
ends up with two transactions (one for the WC data and one for the UC 
trigger) but it could frequently push quite a few descriptors in that 
operation.

	-hpa


-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.
