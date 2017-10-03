From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH 0/5] VSOCK: add sock_diag interface
Date: Tue,  3 Oct 2017 11:39:38 -0400
Message-ID: <20171003153943.23159-1-stefanha@redhat.com>
Cc: Jorgen Hansen <jhansen@vmware.com>,
        Dexuan Cui <decui@microsoft.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19500 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752029AbdJCPju (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Oct 2017 11:39:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is currently no way for userspace to query open AF_VSOCK sockets.  This
means ss(8), netstat(8), and other utilities cannot display AF_VSOCK sockets.

This patch series adds the netlink sock_diag interface for AF_VSOCK.  Userspace
programs sent a DUMP request including an sk_state bitmap to filter sockets
based on their state (connected, listening, etc).  The vsock_diag.ko module
replies with information about matching sockets.  This userspace ABI is defined
in <linux/vm_sockets_diag.h>.

The final patch adds a test suite that exercises the basic cases.

Jorgen and Dexuan: I have only tested the virtio transport but this should also
work for VMCI and Hyper-V.  Please give it a shot if you have time.

Stefan Hajnoczi (5):
  VSOCK: export socket tables for sock_diag interface
  VSOCK: export __vsock_in_bound/connected_table()
  VSOCK: use TCP state constants for sk_state
  VSOCK: add sock_diag interface
  VSOCK: add tools/vsock/vsock_diag_test

 MAINTAINERS                                  |   3 +
 net/vmw_vsock/Makefile                       |   3 +
 tools/vsock/Makefile                         |   9 +
 include/net/af_vsock.h                       |  10 +-
 include/uapi/linux/vm_sockets_diag.h         |  33 ++
 tools/vsock/control.h                        |  13 +
 tools/vsock/timeout.h                        |  14 +
 net/vmw_vsock/af_vsock.c                     |  62 ++-
 net/vmw_vsock/diag.c                         | 186 ++++++++
 net/vmw_vsock/virtio_transport.c             |   2 +-
 net/vmw_vsock/virtio_transport_common.c      |  22 +-
 net/vmw_vsock/vmci_transport.c               |  34 +-
 net/vmw_vsock/vmci_transport_notify.c        |   2 +-
 net/vmw_vsock/vmci_transport_notify_qstate.c |   2 +-
 tools/vsock/control.c                        | 219 +++++++++
 tools/vsock/timeout.c                        |  64 +++
 tools/vsock/vsock_diag_test.c                | 681 +++++++++++++++++++++++++++
 net/vmw_vsock/Kconfig                        |  10 +
 tools/vsock/.gitignore                       |   2 +
 19 files changed, 1312 insertions(+), 59 deletions(-)
 create mode 100644 tools/vsock/Makefile
 create mode 100644 include/uapi/linux/vm_sockets_diag.h
 create mode 100644 tools/vsock/control.h
 create mode 100644 tools/vsock/timeout.h
 create mode 100644 net/vmw_vsock/diag.c
 create mode 100644 tools/vsock/control.c
 create mode 100644 tools/vsock/timeout.c
 create mode 100644 tools/vsock/vsock_diag_test.c
 create mode 100644 tools/vsock/.gitignore

-- 
2.13.6
