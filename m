From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm/vmalloc: export is_vmalloc_or_module_addr
Date: Sat, 8 Feb 2014 12:06:40 -0800
Message-ID: <CA+55aFw2BGS-sPYM1xkO7MfZ_-u=7nF4RYFmoCM99rkL=PxvpA@mail.gmail.com>
References: <1391886730-19667-1-git-send-email-ryao@gentoo.org>
	<1391886730-19667-2-git-send-email-ryao@gentoo.org>
	<CA+55aFx8TzOnW9xPFA4Ox-yFiSUo=cEqeQUmgw_JWjDNEZep8Q@mail.gmail.com>
	<52F68C67.6050606@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
To: Richard Yao <ryao@gentoo.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52F68C67.6050606@gentoo.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 8, 2014 at 11:58 AM, Richard Yao <ryao@gentoo.org> wrote:
>
> My apologies for that. Here is the backtrace:
>
> [<ffffffff814878ce>] p9_virtio_zc_request+0x45e/0x510
> [<ffffffff814814ed>] p9_client_zc_rpc.constprop.16+0xfd/0x4f0
> [<ffffffff814839dd>] p9_client_read+0x15d/0x240
> [<ffffffff811c8440>] v9fs_fid_readn+0x50/0xa0
> [<ffffffff811c84a0>] v9fs_file_readn+0x10/0x20
> [<ffffffff811c84e7>] v9fs_file_read+0x37/0x70
> [<ffffffff8114e3fb>] vfs_read+0x9b/0x160
> [<ffffffff81153571>] kernel_read+0x41/0x60
> [<ffffffff810c83ab>] copy_module_from_fd.isra.34+0xfb/0x180

So copy_module_from_fd() does read into a vmalloc'ed buffer (which
isn't pretty, but at least it's not like using some statically
allocated module data), but that's a regular vmalloc() afaik.

So I don't see the need for "is_vmalloc_or_module_addr()". The regular
"is_vmalloc_addr()" should be fine, and *is* usable from modules (it's
inline, not exported, but it comes to the same thing wrt module use),
exactly because we have traditionally allowed vmalloc'ed memory to be
used.

So is there some reason why it's not just using that simpler function?

The kmap_to_page() thing is actually worse, but that's preexisting damage.

            Linus
