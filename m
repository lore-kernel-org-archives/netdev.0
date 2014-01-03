From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next v2 0/5] bonding: final set of netlink patches
Date: Fri, 03 Jan 2014 14:18:34 -0800
Message-ID: <20140103220806.1659.25199.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com, jiri@resnulli.us, dingtianhong@huawei.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:39560 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753362AbaACWSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 17:18:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2:
====

 - per Jiri's comment, fix ad_select checking against parm table by
   spliting bond_parse_parm() into several funcs.  Go ahead and apply
   same technique to all parameters using parm table.

 - fix netlink msg size to including missing nest attr

 - drop the last patch for active_slaves.  This patch needs to be
   reworked per Jiri's comments and shouldn't hold up finalizing
   the conversion of the existing parameter to netlink attributes.

Ding, assuming this patch set goes in, you should have all you
need to start converting module parameter setting/checking over to
funcs in *_options.c.

I'll send iproute2 patch for bonding netlink support once this patch
set is accepted.

v1:
=====

The following series implements the last set of bonding netlink attributes
for 802.3ad mode:

	lacp_rate
	ad_select
	ad_info, nest of:
		ad_aggregator
		ad_num_ports
		ad_actor_key
		ad_partner_key
		ad_partner_mac

The last patch adds an additional netlink attribute, active_slaves, which
is a nested list of ifindices for current active slaves.  We're using this
list to enable/disable hashing of ports in a hardware LAG implementation.
In the same way bonding driver includes/excludes ports for 802.3ad egress
hashing, hardware ports are included/excluded from egress hashing by
hardware based on port active status.  Yes, data path offloaded to
hardware, control path remains in kernel via bonding driver.

---

Scott Feldman (5):
      bonding: add lacp_rate attribute netlink support
      bonding: add ad_select attribute netlink support
      bonding: add ad_info attribute netlink support
      bonding: fix netlink msg size
      bonding: add bounds checking for tbl params


 drivers/net/bonding/bond_main.c    |   45 +++++++++++------
 drivers/net/bonding/bond_netlink.c |   67 +++++++++++++++++++++++++
 drivers/net/bonding/bond_options.c |   96 ++++++++++++++++++++++++++++++++----
 drivers/net/bonding/bond_sysfs.c   |   69 +++++++++-----------------
 drivers/net/bonding/bonding.h      |    3 +
 include/uapi/linux/if_link.h       |   14 +++++
 6 files changed, 221 insertions(+), 73 deletions(-)

-- 
Signature
