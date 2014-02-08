From: Richard Yao <ryao@gentoo.org>
Subject: [PATCH 0/2] Attention by Linus Torvalds needed to export symbol he wrote
Date: Sat,  8 Feb 2014 14:11:01 -0500
Message-ID: <1391886663-19583-1-git-send-email-ryao@gentoo.org>
Cc: Eric Van Hensbergen <ericvh@gmail.com>,
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
	Brian Behlendorf <behlendorf1@llnl.gov>,
	Matthew Thode <mthode@mthode.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Linus,

Loading kernel modules off 9p-virtio in a Linux guest causes VM termination
because of a page fault in unmapped memory, so I wrote a patch to fix it. Dave
Miller initially accepted it, but then rejected it because it calls an
unexported symbol from a kernel module, which breaks the build when
CONFIG_NET_9P_VIRTIO=m is set in the kernel config:

https://groups.google.com/forum/#!topic/linux.kernel/eRR7AyLE29Y

>From what I can tell, I need the original author of a symbol to sign-off on any
patch exporting it. git blame says that the original author is you, so I am
sending this pull request to you for approval.

Richard Yao (2):
  mm/vmalloc: export is_vmalloc_or_module_addr
  9p/trans_virtio.c: Fix broken zero-copy on vmalloc() buffers

 mm/vmalloc.c          | 1 +
 net/9p/trans_virtio.c | 5 ++++-
 2 files changed, 5 insertions(+), 1 deletion(-)

-- 
1.8.3.2
