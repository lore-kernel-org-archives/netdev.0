From: John Fastabend <john.fastabend@gmail.com>
Subject: [net PATCH v3 0/5] virtio_net XDP fixes and adjust_header support
Date: Thu, 12 Jan 2017 18:50:11 -0800
Message-ID: <20170113024908.4535.8835.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: jasowang@redhat.com, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36807 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750877AbdAMCub (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 21:50:31 -0500
Received: by mail-pf0-f194.google.com with SMTP id b22so6029523pfd.3
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 18:50:31 -0800 (PST)
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

---

John Fastabend (5):
      virtio_net: use dev_kfree_skb for small buffer XDP receive
      net: virtio: wrap rtnl_lock in test for calling with lock already held
      virtio_net: factor out xdp handler for readability
      virtio_net: remove duplicate queue pair binding in XDP
      virtio_net: XDP support for adjust_head


 drivers/net/virtio_net.c |  251 ++++++++++++++++++++++++++++++++--------------
 drivers/virtio/virtio.c  |    9 +-
 include/linux/virtio.h   |    3 +
 3 files changed, 183 insertions(+), 80 deletions(-)
