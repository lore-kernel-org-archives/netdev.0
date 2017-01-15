From: John Fastabend <john.fastabend@gmail.com>
Subject: [net PATCH v4 0/6] virtio_net XDP fixes and adjust_header support
Date: Sun, 15 Jan 2017 15:59:00 -0800
Message-ID: <20170115235528.28980.85142.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: jasowang@redhat.com, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36004 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751173AbdAOX7U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 18:59:20 -0500
Received: by mail-pg0-f67.google.com with SMTP id 75so3805411pgf.3
        for <netdev@vger.kernel.org>; Sun, 15 Jan 2017 15:59:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This has a fix to handle small buffer free logic correctly and then
also adds adjust head support.

I pushed adjust head at net (even though its rc3) to avoid having
to push another exception case into virtio_net to catch if the
program uses adjust_head and then block it. If there are any strong
objections to this we can push it at net-next and use a patch from
Jakub to add the exception handling but then user space has to deal
with it either via try/fail logic or via kernel version checks. Granted
we already have some cases that need to be configured to enable XDP
but I don't see any reason to have yet another one when we can fix it
now vs delaying a kernel version.


v2: fix spelling error, convert unsigned -> unsigned int
v3: v2 git crashed during send so retrying sorry for the noise
v4: changed layout of rtnl_lock fixes (Stephen)
    moved reset logic into virtio core with new patch (MST)
    fixed up linearize and some code cleanup (Jason)

    Otherwise did some generic code cleanup so might be a bit
    cleaner this time at least that is the hope.

Thanks everyone for the v3 review.

---

John Fastabend (6):
      virtio_net: use dev_kfree_skb for small buffer XDP receive
      virtio_net: wrap rtnl_lock in test for calling with lock already held
      virtio_net: factor out xdp handler for readability
      virtio_net: remove duplicate queue pair binding in XDP
      virtio: add pci_down/pci_up configuration
      virtio_net: XDP support for adjust_head


 drivers/net/virtio_net.c        |  228 ++++++++++++++++++++++++---------------
 drivers/virtio/virtio.c         |   14 ++
 drivers/virtio/virtio_balloon.c |    4 -
 drivers/virtio/virtio_input.c   |    4 -
 include/linux/virtio.h          |    5 -
 5 files changed, 152 insertions(+), 103 deletions(-)
