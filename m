From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Wed, 22 Aug 2012 09:59:01 -0700
Message-ID: <50350FD5.8050502@zytor.com>
References: <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com> <503437D4.8090706@zytor.com> <1345601051.2659.93.camel@bwh-desktop.uk.solarflarecom.com> <20120821.193446.1534561579811962053.davem@davemloft.net> <503450E2.2040504@zytor.com> <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com> <1345642009.15245.0.camel@deadeye.wl.decadent.org.uk> <CA+55aFzxhxjOeFSUUJ6XQGUmnaZf7QPSz611zmj2VziEDUB_sA@mail.gmail.com> <1345645499.15245.8.camel@deadeye.wl.decadent.org.uk> <20120822143054.GD9803@kvack.org> <1345647537.2709.0.camel@bwh-desktop.uk.solarflarecom.com> <5034F725.2090802@zytor.com> <AE90C24D6B3A694183C094C60CF0A2F6026B6FC1@saturn3.aculab.com> <1345650689.2709.32.camel@bwh-desktop.uk.solarflarecom.com> <50350098.6030100@zytor.com> <CA+55aFwTyT8v9r7jW2=jp29_yMMacWj
 MwCka+_YktOOMzBHWBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Laight <David.Laight@aculab.com>,
	Benjamin LaHaise <bcrl@kvack.org>,
	David Miller <davem@davemloft.net>, tglx@linutronix.de,
	mingo@redhat.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, x86@kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:44164 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964802Ab2HVQ7S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2012 12:59:18 -0400
In-Reply-To: <CA+55aFwTyT8v9r7jW2=jp29_yMMacWjMwCka+_YktOOMzBHWBw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/22/2012 09:51 AM, Linus Torvalds wrote:
> On Wed, Aug 22, 2012 at 8:54 AM, H. Peter Anvin <hpa@zytor.com> wrote:
>>
>> Sorry, you fail.  There are definitely systems in the field where readq()
>> and writeq() are implemented, because the CPU supports them, where the
>> fabric does not guarantee they are intact.
>
> Indeed.
>
> It's unlikely to be an issue with a PCIe driver, though. I'm pretty
> sure you can rely on 64-bit transfers there, especially with a CPU
> that is modern enough to run 64-bit mode.
>
> That said, even with PCIe, I wonder if older CPU's (think Intel with a
> front-side bus, rather than PCIe on die) necessarily always do 128-bit
> writes. The FSB is just 64 bits wide, and I could *imagine* that a
> PCIe chipset behind the FSB might end up just always generating at
> most 64-bit PCIe transactions for host accesses just because that
> would be "natural".
>
> Sounds unlikely, but hey, hardware sometimes does odd things.
>

I'm wondering how e.g. a K8 would work (CPU -> HT -> PCIe) on UC memory 
there.  I know for a fact that some CPU cores break up SSE transactions 
into 64-bit transactions.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.
