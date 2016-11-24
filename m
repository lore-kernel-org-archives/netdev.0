From: Mark Rutland <mark.rutland@arm.com>
Subject: [PATCH 0/3] virtio/vringh: kill off ACCESS_ONCE()
Date: Thu, 24 Nov 2016 10:25:11 +0000
Message-ID: <1479983114-17190-1-git-send-email-mark.rutland@arm.com>
Cc: dave@stgolabs.net, dbueso@suse.de, dvyukov@google.com,
        jasowang@redhat.com, kvm@vger.kernel.org, mark.rutland@arm.com,
        mst@redhat.com, netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
        virtualization@lists.linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For several reasons, it would be beneficial to kill off ACCESS_ONCE()
tree-wide, in favour of {READ,WRITE}_ONCE(). These work with aggregate types,
more obviously document their intended behaviour, and are necessary for tools
like KTSAN to work correctly (as otherwise reads and writes cannot be
instrumented separately).

While it's possible to script the bulk of this tree-wide conversion, some cases
such as the virtio code, require some manual intervention. This series moves
the virtio and vringh code over to {READ,WRITE}_ONCE(), in the process fixing a
bug in the virtio headers.

Thanks,
Mark.

Mark Rutland (3):
  tools/virtio: fix READ_ONCE()
  vringh: kill off ACCESS_ONCE()
  tools/virtio: use {READ,WRITE}_ONCE() in uaccess.h

 drivers/vhost/vringh.c        | 5 +++--
 tools/virtio/linux/compiler.h | 2 +-
 tools/virtio/linux/uaccess.h  | 9 +++++----
 3 files changed, 9 insertions(+), 7 deletions(-)

-- 
2.7.4
