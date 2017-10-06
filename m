From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH iproute2 v2 0/3] ss: add AF_VSOCK support
Date: Fri,  6 Oct 2017 11:48:38 -0400
Message-ID: <20171006154841.10495-1-stefanha@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Jorgen Hansen <jhansen@vmware.com>,
        Dexuan Cui <decui@microsoft.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55750 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751484AbdJFPsq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Oct 2017 11:48:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2:
 * Use uint64_t instead of __u64 for filter->families
 * Added reference to net-next commit that merged vsock_diag.ko

This patch series adds AF_VSOCK support to ss(8).  AF_VSOCK is a host<->guest
communications channel supported by VMware, KVM (virtio-vsock), and Hyper-V.

To dump AF_VSOCK sockets:

  $ ss --vsock

The vsock_diag.ko module has now been merged in the Linux net-next tree.  I
have verified that the <linux/vm_sockets_diag.h> header copy in this patch
series is in sync with Linux net-next.  See commit
5820299a271fd3dc9b1733e1e10cd7b983edd028 ("Merge branch 'VSOCK-sock_diag'").

Stefan Hajnoczi (3):
  ss: allow AF_FAMILY constants >32
  include: add <linux/vm_sockets_diag.h>
  ss: add AF_VSOCK support

 include/linux/vm_sockets_diag.h |  33 ++++++
 misc/ss.c                       | 238 +++++++++++++++++++++++++++++++++++-----
 man/man8/ss.8                   |   8 +-
 3 files changed, 249 insertions(+), 30 deletions(-)
 create mode 100644 include/linux/vm_sockets_diag.h

-- 
2.13.6
