From: Peng Tao <bergwolf@gmail.com>
Subject: [PATCH v2 0/4] vsock: cancel connect packets when failing to connect
Date: Wed,  7 Dec 2016 23:14:08 +0800
Message-ID: <1481123652-80603-1-git-send-email-bergwolf@gmail.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org, Peng Tao <bergwolf@gmail.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35612 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753220AbcLGPOa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 10:14:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, if a connect call fails on a signal or timeout (e.g., guest is still
in the process of starting up), we'll just return to caller and leave the connect
packet queued and they are sent even though the connection is considered a failure,
which can confuse applications with unwanted false connect attempt.

The patchset enables vsock (both host and guest) to cancel queued packets when
a connect attempt is considered to fail.

v2 changelog:
  - fix queued_replies counting and resume tx/rx when necessary

Peng Tao (4):
  vsock: track pkt owner vsock
  vhost-vsock: add pkt cancel capability
  vsock: add pkt cancel capability
  vsock: cancel packets when failing to connect

 drivers/vhost/vsock.c                   | 41 ++++++++++++++++++++++++++++++++
 include/linux/virtio_vsock.h            | 12 ++++++++++
 net/vmw_vsock/af_vsock.c                |  7 ++++++
 net/vmw_vsock/virtio_transport.c        | 42 +++++++++++++++++++++++++++++++++
 net/vmw_vsock/virtio_transport_common.c | 14 +++++------
 5 files changed, 109 insertions(+), 7 deletions(-)

-- 
2.7.4
