From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH iproute2 V1 0/5] RDMAtool
Date: Tue, 27 Jun 2017 17:39:14 +0300
Message-ID: <20170627143920.28020-1-leon@kernel.org>
Cc: Leon Romanovsky <leonro@mellanox.com>,
        Doug Ledford <dledford@redhat.com>,
        Ariel Almog <ariela@mellanox.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Linux RDMA <linux-rdma@vger.kernel.org>,
        Linux Netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:39712 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752573AbdF0Oja (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Jun 2017 10:39:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

Hi,

This is second version of series implementing the RDAMtool -  the tool
to configure RDMA devices. The initial proposal was sent as RFC [1] and
was based on sysfs entries as POC.

The current series was rewritten completely to work with RDMA netlinks as
a source of user<->kernel communications. In order to achieve that, the
RDMA netlinks were extensively refactored and modernized [2, 3, 4 and 5].

Changelog
v0->v1:
 * Moved hunk with changes in man/Makefile from first patch to the last patch
 * Removed the "unknown command" from the examples in commit messages
 * Removed special "caps" parsing command and put it to be part of general "show" command
 * Changed parsed capability format to be similar to iproute2 suite
 * Added FW version as an output of show command.
 * Added forgotten CAP_FLAGS to the nla_policy list
RFC->v0:
 * Removed everything that is not implemented yet.
 * Abandoned sysfs interfaces in favor of netlink.

Available in the "topic/rdmatool-netlink-v1" topic branch of this git repo:
git://git.kernel.org/pub/scm/linux/kernel/git/leon/iproute2.git

Or for browsing:
https://git.kernel.org/cgit/linux/kernel/git/leon/iproute2.git/log/?h=topic/rdmatool-netlink-v1

Thanks

[1] https://www.spinics.net/lists/linux-rdma/msg49575.html
[2] https://patchwork.kernel.org/patch/9752865/
[3] https://www.spinics.net/lists/linux-rdma/msg50827.html
[4] https://www.spinics.net/lists/linux-rdma/msg51210.html
[5] https://patchwork.kernel.org/patch/9811729/ and https://patchwork.kernel.org/patch/9811731/]

Cc: Doug Ledford <dledford@redhat.com>
Cc: Ariel Almog <ariela@mellanox.com>
Cc: Dennis Dalessandro <dennis.dalessandro@intel.com>
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Linux RDMA <linux-rdma@vger.kernel.org>
Cc: Linux Netdev <netdev@vger.kernel.org>

Leon Romanovsky (6):
  rdma: Add basic infrastructure for RDMA tool
  rdma: Add dev object
  rdma: Add device capability parsing
  rdma: Add link option and parsing
  rdma: Add FW version to the device output
  rdma: Add initial manual for the tool

 Makefile          |   2 +-
 man/man8/Makefile |   3 +-
 man/man8/rdma.8   |  82 ++++++++++++++
 rdma/.gitignore   |   1 +
 rdma/Makefile     |  22 ++++
 rdma/dev.c        | 145 +++++++++++++++++++++++++
 rdma/link.c       | 202 +++++++++++++++++++++++++++++++++++
 rdma/rdma.c       | 112 ++++++++++++++++++++
 rdma/rdma.h       |  90 ++++++++++++++++
 rdma/utils.c      | 312 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 10 files changed, 969 insertions(+), 2 deletions(-)
 create mode 100644 man/man8/rdma.8
 create mode 100644 rdma/.gitignore
 create mode 100644 rdma/Makefile
 create mode 100644 rdma/dev.c
 create mode 100644 rdma/link.c
 create mode 100644 rdma/rdma.c
 create mode 100644 rdma/rdma.h
 create mode 100644 rdma/utils.c
