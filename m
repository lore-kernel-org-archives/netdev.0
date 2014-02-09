From: Richard Yao <ryao@gentoo.org>
Subject: [PATCH] Fix broken zero-copy on vmalloc() buffers (4th and hopefully final submission)
Date: Sat,  8 Feb 2014 19:32:00 -0500
Message-ID: <1391905921-28378-1-git-send-email-ryao@gentoo.org>
Cc: Eric Van Hensbergen <ericvh@gmail.com>,
	Ron Minnich <rminnich@sandia.gov>,
	Latchesar Ionkov <lucho@ionkov.net>,
	V9FS Develooper Mailing List
	<v9fs-developer@lists.sourceforge.net>,
	Linux Netdev Mailing List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
	Will Deacon <will.deacon@arm.com>,
	Christopher Covington <cov@codeaurora.org>,
	Matthew Thode <mthode@mthode.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch has been submitted for a few times.

The first time was my first time doing any sort of Linux patch
submission. At the time, I was unaware of ./scripts/get_maintainer.pl
and sent the patch to only a subset of the correct people. Consequently,
it was not submitted properly for acceptance by the subsystem maintainer.

The second time was a week ago. I had taken advice from Greg Koah-Hartman to
use ./scripts/get_maintainer.pl to determine the correct recipients. It was
initially accepted by the subsystem maintainer and then rejected. This patch
uses is_vmalloc_or_module_addr(), which is not exported for use in kernel
modules. Using it causes a build failure when CONFIG_NET_9P_VIRTIO=m is set in
.config.

The third time was earlier today, when I sent it straight to Linus Torvalds
because merging it required exporting is_vmalloc_or_module_addr(), which he
wrote. A brief correspondence with Linus revealed that my earlier belief that
it would be better to use is_vmalloc_or_module_addr() instead of
is_vmalloc_addr() was incorrect.

I expect this submission to be the last. I have changed the patch to use
is_vmalloc_addr() as Linus Torvalds suggested. This resolves the build
regression the problem David S. Miller found when CONFIG_NET_9P_VIRTIO=m was
set and should resolve all criticism.

Richard Yao (1):
  9p/trans_virtio.c: Fix broken zero-copy on vmalloc() buffers

 net/9p/trans_virtio.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

-- 
1.8.3.2
