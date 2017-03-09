From: Sagi Grimberg <sagi@grimberg.me>
Subject: [PATCH v3 0/4] Introduce a new helper for parsing ipv[4|6]:port to socket address
Date: Thu,  9 Mar 2017 14:49:49 +0200
Message-ID: <1489063793-12838-1-git-send-email-sagi@grimberg.me>
Cc: Christoph Hellwig <hch@lst.de>
To: linux-nvme@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:54438 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750770AbdCIMt6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 07:49:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes from v1:
- rebased to 4.11-rc1
- improved changelogs

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
