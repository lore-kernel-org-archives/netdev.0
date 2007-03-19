From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap
 paravirt ops callsites to make them patchable
Date: Mon, 19 Mar 2007 13:06:14 -0700
Message-ID: <45FEED36.9030302@goop.org>
References: <1174272469.11680.23.camel@localhost.localdomain>	<m1648xxf93.fsf@ebiederm.dsl.xmission.com>	<45FEE010.1050103@goop.org>
	<20070319.124636.59653632.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: zach@vmware.com, xen-devel@lists.xensource.com,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	rusty@rustcorp.com.au, linux-kernel@vger.kernel.org,
	chrisw@sous-sol.org, ak@muc.de, ebiederm@xmission.com,
	anthony@codemonkey.ws, mingo@elte.hu,
	torvalds@linux-foundation.org, akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <20070319.124636.59653632.davem@davemloft.net>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

David Miller wrote:
> Another point worth making is that for function calls you
> can fix things up lazily if you want.
> [...]
> In fact forget I mentioned this idea :)
>   

OK :)  I think we'll only ever want to bind to a hypervisor once, since
the underlying hypervisor can't change on the fly (well, in principle it
might if you migrate, but you'll have more problems than just dealing
with the hook points).  And lazy binding doesn't buy much; I think its
much better to get it all out of the way at once, and then throw the
reloc info away.

> As another note, I do agree with Linus about the register usage
> arguments.  It is important.  I think it's been mentioned but what you
> could do is save nothing (so that "sti" and "cli" are just that and
> cost nothing), but the more complicated versions save and restore
> enough registers to operate.
>   

Right, that's pretty much what we do now.

> It all depends upon what you're trying to do.  For example, it's
> easy to use patching to make different PTE layouts be supportable
> in the same kernel image.  We do this on sparc64 since sun4v
> has a different PTE layout than sun4u, you can see the code in
> asm-sparc64/pgtable.h for details (search for "sun4v_*_patch")
>   

I see.  We want to do something conceptually like this, but we need to
handle more than just adjusting which of two constants to use as a
mask.  For example, Xen needs to run pfns through a pfn->mfn (machine
frame number) conversion and back when making/unpacking pagetable entries.

    J
