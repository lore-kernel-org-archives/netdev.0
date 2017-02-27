From: Sagi Grimberg <sagi@grimberg.me>
Subject: [PATCH v1 0/4] Introduce a new helper for parsing ipv[4|6]:port to socket address
Date: Mon, 27 Feb 2017 19:39:20 +0200
Message-ID: <1488217164-9221-1-git-send-email-sagi@grimberg.me>
To: linux-nvme@lists.infradead.org, target-devel@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:40042 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751039AbdB0Rlu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 12:41:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes from v0:
- rebased on 4.10
- splitted inet_pton_with_scope to be a bit saner (from Chrsitoph)
- converted nvme-rdma host_traddr to use a generic helper

We have some places in the stack that support ipv4 and ipv6. In
some cases the user configuration does not reveal which
address family is given and needs to be parsed from the input string.

Given that the user-input varies between subsystems, some processing
is required from the call-site to separate address and port strings.

As a side-effect, this set adds ipv6 support for nvme over fabrics.

Sagi Grimberg (4):
  net/utils: generic inet_pton_with_scope helper
  nvmet-rdma: use generic inet_pton_with_scope
  nvme-rdma: use inet_pton_with_scope helper
  iscsi-target: use generic inet_pton_with_scope

 drivers/nvme/host/rdma.c                     |  63 +++++-----------
 drivers/nvme/target/rdma.c                   |  42 +++++++----
 drivers/target/iscsi/iscsi_target_configfs.c |  46 ++++--------
 include/linux/inet.h                         |   6 ++
 net/core/utils.c                             | 103 +++++++++++++++++++++++++++
 5 files changed, 169 insertions(+), 91 deletions(-)

-- 
2.7.4
