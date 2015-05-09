From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: [PATCH linux v3 net-next 0/5] add netlink support for new lacp bonding parameters
Date: Sat,  9 May 2015 00:01:54 -0700
Message-ID: <cover.1431150701.git.jtoppins@cumulusnetworks.com>
To: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	shm@cumulusnetworks.com, razor@blackwall.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:33247 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575AbbEIHC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 03:02:26 -0400
Received: by pdbnk13 with SMTP id nk13so105463335pdb.0
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 00:02:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a resubmit of Mahesh's last 3 bonding patches from this series
(http://marc.info/?l=linux-netdev&m=142432864626179&w=2) with one
additional kernel patch which adds the netlink bits. I have noted any
modifications I did to the original patches just above my signoff line.
Patch 5 is the iproute2 support for these bonding options. All patches
were coded against the net-next branch of their respective projects.

v2:
  * rebased
  * only send these new parameters via netlink when bond is in mode 4
  * fixed ad_actor_sys_prio to be 0xFFFF by default even when the bond
    is initially created in mode 0 and switched to mode 4

v3:
  * reverted changes to bond_option_ad_actor_system_set() from v1 in Mahesh's
    patch "bonding: Allow userspace to set actors' macaddr in an AD-system."
    Instead implementing all setting in the option specific set function as
    Nik suggested.

Kernel series:

Andy Gospodarek (1):
  bonding: add netlink support for sys prio, actor sys mac, and port
    key

Mahesh Bandewar (3):
  bonding: Allow userspace to set actors' system_priority in AD system
  bonding: Allow userspace to set actors' macaddr in an AD-system.
  bonding: Implement user key part of port_key in an AD system.

 Documentation/networking/bonding.txt |   84 +++++++++++++++++++++++++++++++
 drivers/net/bonding/bond_3ad.c       |   26 ++++++----
 drivers/net/bonding/bond_main.c      |   23 +++++++++
 drivers/net/bonding/bond_netlink.c   |   50 +++++++++++++++++++
 drivers/net/bonding/bond_options.c   |   91 ++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bond_procfs.c    |    8 +++
 drivers/net/bonding/bond_sysfs.c     |   46 +++++++++++++++++
 include/net/bond_options.h           |    3 ++
 include/net/bonding.h                |    3 ++
 include/uapi/linux/if_link.h         |    3 ++
 10 files changed, 328 insertions(+), 9 deletions(-)

iproute2 series:

Jonathan Toppins (1):
      iplink_bond: add support for ad_actor and port_key options

 ip/iplink_bond.c |   49 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 49 insertions(+)

-- 
1.7.10.4
