From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next 0/4] bonding: final set of netlink patches
Date: Fri, 27 Dec 2013 23:15:34 -0800
Message-ID: <20131228065712.6296.34291.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com, jiri@resnulli.us
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:48557 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751071Ab3L1HPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Dec 2013 02:15:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

Scott Feldman (4):
      bonding: add lacp_rate attribute netlink support
      bonding: add ad_select attribute netlink support
      bonding: add ad_info attribute netlink support
      bonding: add active_slaves attribute


 drivers/net/bonding/bond_netlink.c |  100 +++++++++++++++++++++++++++++++++
 drivers/net/bonding/bond_options.c |   51 +++++++++++++++++
 drivers/net/bonding/bond_sysfs.c   |  108 +++++++++++++++++++++---------------
 drivers/net/bonding/bonding.h      |    2 +
 include/uapi/linux/if_link.h       |   15 +++++
 5 files changed, 229 insertions(+), 47 deletions(-)

-- 
Signature
