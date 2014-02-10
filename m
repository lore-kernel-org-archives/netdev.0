From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm/vmalloc: export is_vmalloc_or_module_addr
Date: Mon, 10 Feb 2014 11:43:39 -0800
Message-ID: <CA+55aFx1zipV70iTtuyciu36_dLRre7db09XRUDWUrLW2wLA0g@mail.gmail.com>
References: <1391886730-19667-1-git-send-email-ryao@gentoo.org>
	<1391886730-19667-2-git-send-email-ryao@gentoo.org>
	<CA+55aFx8TzOnW9xPFA4Ox-yFiSUo=cEqeQUmgw_JWjDNEZep8Q@mail.gmail.com>
	<52F68C67.6050606@gentoo.org>
	<CA+55aFw2BGS-sPYM1xkO7MfZ_-u=7nF4RYFmoCM99rkL=PxvpA@mail.gmail.com>
	<52F6972C.2030307@gentoo.org>
	<CA+55aFzzxcrLrUaCrzFbwS_74B2iHd3OvQ=WC-DR-rqpOA0j0A@mail.gmail.com>
	<52F929A6.8040209@mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Richard Yao <ryao@gentoo.org>, Mel Gorman <mgorman@suse.de>,
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
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52F929A6.8040209@mit.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 10, 2014 at 11:33 AM, Andy Lutomirski <luto@amacapital.net> wrote:
>
> I agree that reading to module space is awful, but is it obviously
> terrible for a module to do this:
>
> static const char header[] = {...};
> kernel_write(file, header, sizeof(header), 0);

Yes, it is terrible. Don't do it. It shouldn't work.

Now, whether it is "obvious" or not is immaterial. It might be hard to
notice, but let's face it, we are kernel programmers. Our interfaces
aren't designed for convenience, they are for working well and
efficiently.  And if that happens to mean that you shouldn't do IO on
kmap'ed pages, or use random static data in your modules, that is what
it means.

We have lots of other rules too. People should deal with it, and
realize that in the kernel we absolutely *have* to try to minimize the
problem space as much as possible.

The usual computer sciencey approach of "make things as generic as
possible so that you can reuse the code" stuff is generally bullshit
even in other contexts (example: STL), but it's _particularly_ bad for
the kernel. It's much better to have strict rules about what is
acceptable.

                Linus
