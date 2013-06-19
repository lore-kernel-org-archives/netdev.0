From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 0/6] bonding: prepare to and add arp_all_targets
Date: Wed, 19 Jun 2013 19:34:40 +0200
Message-ID: <1371663286-12518-1-git-send-email-vfalico@redhat.com>
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net, linux@8192.net, nicolas.2p.debian@free.fr,
	rick.jones2@hp.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5435 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756707Ab3FSRef (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jun 2013 13:34:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset does some cleanup, fixes a few flaws and adds a new parameter
to control whether the slave should stay up when any of arp_ip_targets are
up or all of them are up (i.e. if the slave should go down if even one
target from arp_ip_targets fail).

The patches 1-5 basicly prepare the bonding code to work properly with this
new parameter, however it's not depending on them.

All comments are really welcome.

Thanks!

Veaceslav Falico (6):
      bonding: verify if bond has ip only once on arp validate
      bonding: add helper function bond_get_targets_ip(targets, ip)
      bonding: don't add duplicate targets to arp_ip_target
      bonding: don't validate arp if we don't have to
      bonding: don't swap arp's ips on validation for backup slave
      bonding: add an option to fail when any of arp_ip_target is inaccessible

 Documentation/networking/bonding.txt |   41 +++++++++-----
 drivers/net/bonding/bond_main.c      |   79 ++++++++++++++++++---------
 drivers/net/bonding/bond_sysfs.c     |  100 +++++++++++++++++++++++-----------
 drivers/net/bonding/bonding.h        |   46 +++++++++++++++-
 4 files changed, 191 insertions(+), 75 deletions(-)
