From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULLv2] vhost: cleanups and fixes
Date: Thu, 2 May 2013 23:11:06 +0300
Message-ID: <20130502201106.GA17385@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	asias@redhat.com, mst@redhat.com, nab@linux-iscsi.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52263 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761277Ab3EBULW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 May 2013 16:11:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Linus,
This is exactly same code as my previous pull sent earlier, the diffstat
was wrong however, I did a merge with master which fixed that.  And I
forgot to copy you so you likely
did not see it at all :(
Here comes.

The following changes since commit 5a148af66932c31814e263366094b5812210b501:

  Merge branch 'next' of git://git.kernel.org/pub/scm/linux/kernel/git/benh/powerpc (2013-05-02 10:16:16 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus2

for you to fetch changes up to ef1f2e2ae31069a3484f77f00ea6ef92031d611a:

  Merge branch 'vhost' into 'master' (2013-05-02 22:40:01 +0300)

----------------------------------------------------------------

vhost: cleanups and fixes for 3.10

Here are vhost cleanups and fixes by Asias He and myself.
They affect both vhost-net and vhost-scsi devices.
They also *depend* on both net-next and target-pending,
where the net and target commits these changes depend on
are already merged.
So merging through the common vhost tree.
Note2: I had to make a merge from vhost into master otherwise
request-pull generates a wrong diffstat.
It's harmless since git merge will figure it all out
easily.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Asias He (3):
      vhost: Allow device specific fields per vq
      tcm_vhost: Wait for pending requests in vhost_scsi_flush()
      vhost: move vhost-net zerocopy fields to net.c

Michael S. Tsirkin (9):
      Merge branch 'for-next-merge' of git://git.kernel.org/.../nab/target-pending into vhost-net-next
      tcm_vhost: document inflight ref-counting use
      vhost: move per-vq net specific fields out to net
      tcm_vhost: remove virtio-net.h dependency
      vhost: fix error handling in RESET_OWNER ioctl
      vhost: src file renames
      tcm_vhost: header split up
      vhost_scsi: module rename
      Merge branch 'vhost' into 'master'

 drivers/vhost/Kconfig                 |  10 +-
 drivers/vhost/Kconfig.tcm             |   6 -
 drivers/vhost/Makefile                |   3 +-
 drivers/vhost/net.c                   | 255 +++++++++++++++++++++++++++-------
 drivers/vhost/{tcm_vhost.c => scsi.c} | 255 +++++++++++++++++++++++++++++++---
 drivers/vhost/tcm_vhost.h             | 128 -----------------
 drivers/vhost/test.c                  |   9 +-
 drivers/vhost/vhost.c                 | 153 +++++++-------------
 drivers/vhost/vhost.h                 |  32 +----
 include/uapi/linux/vhost.h            |  28 ++++
 10 files changed, 533 insertions(+), 346 deletions(-)
 delete mode 100644 drivers/vhost/Kconfig.tcm
 rename drivers/vhost/{tcm_vhost.c => scsi.c} (86%)
 delete mode 100644 drivers/vhost/tcm_vhost.h
