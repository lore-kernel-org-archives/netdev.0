From: Richard Yao <ryao@gentoo.org>
Subject: Re: [PATCH 1/2] mm/vmalloc: export is_vmalloc_or_module_addr
Date: Sat, 8 Feb 2014 18:39:12 -0500
Message-ID: <F8F0FCFB-1123-4374-BF69-A77BB3AF800A@gentoo.org>
References: <1391886730-19667-1-git-send-email-ryao@gentoo.org> <1391886730-19667-2-git-send-email-ryao@gentoo.org> <CA+55aFx8TzOnW9xPFA4Ox-yFiSUo=cEqeQUmgw_JWjDNEZep8Q@mail.gmail.com> <52F68C67.6050606@gentoo.org> <CA+55aFw2BGS-sPYM1xkO7MfZ_-u=7nF4RYFmoCM99rkL=PxvpA@mail.gmail.com> <52F6972C.2030307@gentoo.org> <CA+55aFzzxcrLrUaCrzFbwS_74B2iHd3OvQ=WC-DR-rqpOA0j0A@mail.gmail.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Mel Gorman <mgorman@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Rik van Riel <riel@redhat.com>,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Ron Minnich <rminnich@sandia.gov>,
	Latchesar Ionkov <lucho@ionkov.net>,
	"David S. Miller" <davem@davemloft.net>,
	V9FS Develooper Mailing List
	<v9fs-developer@lists.sourceforge.net>,
	Linux Netdev Mailing List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
	Will Deacon <will.deacon@arm.com>,
	Christopher Covington <cov@codeaurora.org>,
	Matthew Thode <mthode@mthode.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFzzxcrLrUaCrzFbwS_74B2iHd3OvQ=WC-DR-rqpOA0j0A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Feb 8, 2014, at 5:24 PM, Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Sat, Feb 8, 2014 at 12:44 PM, Richard Yao <ryao@gentoo.org> wrote:
>> 
>> However, is_vmalloc_addr() only applies to the vmalloc region. While all
>> architectures load kernel modules into virtual memory (to my knowledge),
>> some architectures do not load them into the vmalloc region.
> 
> So?
> 
> People shouldn't do IO to module data, so who cares if something is a
> module address or not?
> 
> The thing is, even module *loading* doesn't do IO to the magic module
> addresses - it loads the module data into regular vmalloc space, and
> then copies it into the final location separately.
> 
> And no module should ever do any IO on random static data (and
> certainly not on code).
> 
> So there is _zero_ reason for a driver or a filesystem to use
> is_vmalloc_or_module_addr(). It's just not a valid question to ask.
> 
> If somebody uses module data/code addresses, we're *better* off with a
> oops or other nasty behavior than to try to make it "work".
> 
>            Linus

I will modify this to use is_vmalloc_addr() and send it back to the appropriate subsystem maintainer(s). Thank-you for taking the time to write that explanation.