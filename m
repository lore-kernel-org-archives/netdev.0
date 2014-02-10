From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/2] mm/vmalloc: export is_vmalloc_or_module_addr
Date: Mon, 10 Feb 2014 12:10:20 +0000
Message-ID: <20140210121020.GC6732@suse.de>
References: <1391886730-19667-1-git-send-email-ryao@gentoo.org>
 <1391886730-19667-2-git-send-email-ryao@gentoo.org>
 <CA+55aFx8TzOnW9xPFA4Ox-yFiSUo=cEqeQUmgw_JWjDNEZep8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Dave Kleikamp <dave.kleikamp@oracle.com>,
	Richard Yao <ryao@gentoo.org>,
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
Content-Disposition: inline
In-Reply-To: <CA+55aFx8TzOnW9xPFA4Ox-yFiSUo=cEqeQUmgw_JWjDNEZep8Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 08, 2014 at 11:45:53AM -0800, Linus Torvalds wrote:
> On Sat, Feb 8, 2014 at 11:12 AM, Richard Yao <ryao@gentoo.org> wrote:
> > 9p-virtio needs is_vmalloc_or_module_addr exported before a patch can be
> > merged to prevent the virtio zero-copy routines from triggering a
> > hypervisor page fault when loading kernel modules:
> >
> > https://groups.google.com/forum/#!topic/linux.kernel/eRR7AyLE29Y
> >
> > Without this export, the kernel build breaks with that patch applied and
> > CONFIG_NET_9P_VIRTIO=m. With this export in place, all is well.
> 
> I absolutely *detest* this patch.
> 
> Not so much because is_vmalloc_or_module_addr() should never be used,
> but because the particular use in question is pure and utter garbage.
> 
> There are valid reasons to use "is_vmalloc_or_module_addr()", but
> those are along the lines of drivers/char/mem.c, which says "return
> -ENXIO for this crap".
> 
> And btw, that horrid crap called "kmap_to_page()" needs to die too.
> When is it *ever* valid to use a kmap'ed page for IO? Here's a clue:
> never.
> 
> <SNIP>
>
> Those *disgusting* get_kernel_page[s]() functions came with a
> commentary about "The initial user is expected to be NFS.." and that
> is still the *only* user. The fact that *everybody* else has been able
> to avoid that crap should tell us something.

kmap_to_page, get_kernel_page and the NFS user for it are already scheduled
for death. Dave Kleikamp has been working on a series "Issue O_DIRECT aio
using bio_vec" that replaces what NFS currently does with something far
more sane. The series does not remove the helpers on top, probably because
of the 9P use of it, but if that was changed then the helpers would finally
die. I'm not sure why Dave's series never got merged so added him to the
cc to find out.

-- 
Mel Gorman
SUSE Labs
