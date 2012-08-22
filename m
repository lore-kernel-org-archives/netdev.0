From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Wed, 22 Aug 2012 08:51:40 -0700
Message-ID: <5035000C.1060907@zytor.com>
References: <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com>  <503437D4.8090706@zytor.com>  <1345601051.2659.93.camel@bwh-desktop.uk.solarflarecom.com>  <20120821.193446.1534561579811962053.davem@davemloft.net>  <503450E2.2040504@zytor.com>  <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com>  <1345642009.15245.0.camel@deadeye.wl.decadent.org.uk>  <CA+55aFzxhxjOeFSUUJ6XQGUmnaZf7QPSz611zmj2VziEDUB_sA@mail.gmail.com>  <1345645499.15245.8.camel@deadeye.wl.decadent.org.uk>  <20120822143054.GD9803@kvack.org> <1345647537.2709.0.camel@bwh-desktop.uk.solarflarecom.com> <5034F725.2090802@zytor.com> <AE90C24D6B3A694183C094C60CF0A2F6026B6FC1@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Benjamin LaHaise <bcrl@kvack.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>, tglx@linutronix.de,
	mingo@redhat.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, x86@kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:43540 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757214Ab2HVPv7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2012 11:51:59 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6FC1@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/22/2012 08:27 AM, David Laight wrote:
>> Your architecture sounds similar to one I once worked on (Orion
>> Microsystems CNIC/OPA-2).  That architecture had a descriptor ring in
>> device memory, and a single trigger bit would move the head pointer.
>>
>> We used write combining to write out a set of descriptors, and then
>> used
>> a non-write-combining write to do the final write which bumps the head
>> pointer.  The UC write flushes the write combiners ahead of it, so it
>> ends up with two transactions (one for the WC data and one for the UC
>> trigger) but it could frequently push quite a few descriptors in that
>> operation.
>
> The code actually looks more like a normal ethernet ring interface
> with an 'owner' bit in each entry.
> So it is important to write the owner bit last.
>
> It might be possibly to set multiple ring entries in two TLPs
> by first writing all of them (maybe with write combining)
> but without changing the ownership of the first entry.
> Then doing a second transfer to update the owner bit it
> the first entry.
> The order of the writes in the first transfer would then not
> matter.
>

The design flaw in that kind of design would be the need to set the 
owner bit on every entry.  Now, in the case of CNIC/OPA-2 support for 
write combining was an explicit design goal, so writes are inert until 
the trigger bit is written, at which point the head pointer is moved to 
the entry containing the trigger bit.  Very effective.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.
