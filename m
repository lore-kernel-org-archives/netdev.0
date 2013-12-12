From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next v2 0/8] bonding: add more netlink attributes
Date: Thu, 12 Dec 2013 14:09:48 -0800
Message-ID: <20131212214558.21629.92365.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:53228 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751496Ab3LLWJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 17:09:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2:

Addressed v1 review comments.  In particular, Jay's concern about
current sysfs ordering limitations carrying over to iproute.  Netlink
attributes are processed in a priority order in
bond_netlink.c:bond_changelink().  Lower priority attributes can't undo
higher priority attributes when attempting to set both with iproute
command.  For example, this command will fail:

  ip link add bond1 type bond mode active-backup miimon 10 arp_interval 10

Because we're trying to create a new bond to use incompatible miimon
and ARP interval attributes.  However, if attributes are applied
one-at-a-time, previously applied attributes can be overridden:

  ip link add bond1 type bond mode active-backup miimon 10
  ip link set dev bond1 type bond arp_interval 10

These two commands succeed.  The bond is first created to use miimon.
Next, the bond is converted to use ARP interval, which undoes miimon.

v1:

Following Jiri Pirko's lead, add more bonding netlink attributes.  Sending
matching iproute2 patch separately.  sysfs access to attributes is
retained.

---

Scott Feldman (8):
      bonding: add miimon netlink support
      bonding: add updelay netlink support
      bonding: add downdelay netlink support
      bonding: add use_carrier netlink support
      bonding: add arp_interval netlink support
      bonding: add arp_ip_target netlink support
      bonding: add arp_validate netlink support
      bonding: add arp_all_targets netlink support


 drivers/net/bonding/bond_netlink.c |  157 ++++++++++++++++
 drivers/net/bonding/bond_options.c |  324 +++++++++++++++++++++++++++++++++
 drivers/net/bonding/bond_sysfs.c   |  349 +++++++++---------------------------
 drivers/net/bonding/bonding.h      |   11 +
 include/uapi/linux/if_link.h       |    8 +
 5 files changed, 578 insertions(+), 271 deletions(-)

-- 
Signature
