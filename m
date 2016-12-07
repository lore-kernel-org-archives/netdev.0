From: Peng Tao <bergwolf@gmail.com>
Subject: [PATCH 0/4] vsock: cancel connect packets when failing to connect
Date: Wed,  7 Dec 2016 18:00:17 +0800
Message-ID: <1481104821-77294-1-git-send-email-bergwolf@gmail.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org, Peng Tao <bergwolf@gmail.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34772 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751654AbcLGKCv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 05:02:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, if a connect call fails on a signal or timeout (e.g., guest is still
in the process of starting up), we'll just return to caller and leave the connect
packet queued and they are sent even though the connection is considered a failure,
which can confuse applications with unwanted false connect attempt.

The patchset enables vsock (both host and guest) to cancel queued packets when
a connect attempt is considered to fail.

Peng Tao (4):
  vsock: track pkt owner vsock
  vhost-vsock: add pkt cancel capability
  vsock: add pkt cancel capability
  vsock: cancel packets when failing to connect

 drivers/vhost/vsock.c                   | 29 ++++++++++++++++++++++++++
 include/linux/virtio_vsock.h            | 12 +++++++++++
 net/vmw_vsock/af_vsock.c                |  7 +++++++
 net/vmw_vsock/virtio_transport.c        | 36 +++++++++++++++++++++++++++++++++
 net/vmw_vsock/virtio_transport_common.c | 14 ++++++-------
 5 files changed, 91 insertions(+), 7 deletions(-)

-- 
2.7.4
