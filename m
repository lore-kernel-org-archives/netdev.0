From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next v2 0/2] bonding: add slave netlink and sysfs support
Date: Thu, 16 Jan 2014 22:57:42 -0800
Message-ID: <20140117065316.3194.94624.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com, dingtianhong@huawei.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:36368 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751094AbaAQG5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 01:57:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2:

  - Address review comment from Ding (and Veacesiav): handle kobj cleanup
    if sysfs_create_file() fails when adding slave attribute nodes.

v1:

  The following series adds bonding slave netlink and sysfs interfaces.
  Slave interfaces get a new IFLA_SLAVE set of netlink attributes, along
  with RTM_NEWLINK notification when slave's active status changes.  The
  sysfs interface adds read-only nodes for slave attributes under a /slave
  dir, simliar to how bond interfaces get a /bonding dir for bonding
  attributes.

---

Scott Feldman (2):
      bonding: add sysfs /slave dir for bond slave devices.
      bonding: add netlink attributes to slave link dev


 drivers/net/bonding/Makefile           |    2 
 drivers/net/bonding/bond_main.c        |   28 ++++++
 drivers/net/bonding/bond_netlink.c     |   36 ++++++++
 drivers/net/bonding/bond_procfs.c      |   12 ---
 drivers/net/bonding/bond_sysfs_slave.c |  144 ++++++++++++++++++++++++++++++++
 drivers/net/bonding/bonding.h          |   15 +++
 include/linux/netdevice.h              |    5 +
 include/uapi/linux/if_link.h           |   13 +++
 net/core/rtnetlink.c                   |   54 ++++++++++++
 9 files changed, 294 insertions(+), 15 deletions(-)
 create mode 100644 drivers/net/bonding/bond_sysfs_slave.c

-- 
Signature
