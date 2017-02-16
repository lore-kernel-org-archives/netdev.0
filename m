From: Sagi Grimberg <sagi@grimberg.me>
Subject: [PATCH rfc 0/4] Introduce a new helper for parsing ipv[4|6]:port to socket address
Date: Thu, 16 Feb 2017 19:43:33 +0200
Message-ID: <1487267017-29904-1-git-send-email-sagi@grimberg.me>
To: linux-nvme@lists.infradead.org, linux-rdma@vger.kernel.org,
        target-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <target-devel-owner@vger.kernel.org>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We have some places in the stack that support ipv4 and ipv6. In
some cases the user configuration does not reveal which
address family is given and needs to be parsed from the input string.

Given that the user-input varies between subsystems, some processing
is required from the call-site to separate address and port strings.

As a side-effect, this set adds ipv6 support for nvme over fabrics.
I also converted iscsi target and plan to convert nfs/cifs next but
wanted to get some feedback before doing that.

patch #1 is based off roland's patch:
http://lists.infradead.org/pipermail/linux-nvme/2016-August/005600.html

Sagi Grimberg (4):
  net/utils: generic inet_pton_with_scope helper
  nvmet-rdma: use generic inet_pton_with_scope
  nvme-rdma: use inet_pton_with_scope helper
  iscsi-target: use generic inet_pton_with_scope

 drivers/nvme/host/rdma.c                     | 48 ++++-----------
 drivers/nvme/target/rdma.c                   | 42 +++++++++----
 drivers/target/iscsi/iscsi_target_configfs.c | 46 ++++----------
 include/linux/inet.h                         |  6 ++
 net/core/utils.c                             | 91 ++++++++++++++++++++++++++++
 5 files changed, 151 insertions(+), 82 deletions(-)

-- 
2.7.4
