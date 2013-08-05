From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 0/3] bonding: vlan handling changes
Date: Mon,  5 Aug 2013 15:28:21 +0200
Message-ID: <1375709304-16778-1-git-send-email-nikolay@redhat.com>
Cc: fubar@us.ibm.com, andy@greyhouse.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14492 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752156Ab3HENce (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Aug 2013 09:32:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <Nikolay Aleksandrov nikolay@redhat.com>

Hi,
I've queued all of these patches to net-next since they're tightly related
and the bugs that get fixed are not critical, so it's better to soak the
changes a bit. Also I'd much rather fix this with the slave list change in.
If you decide that they need to be posted for -net, let me know.

Patch 01 - fixes vlan 0 addition/removal since when we have 8021q module
loaded it gets added to all network devices, this causes the bonding to
output false warnings, output tagged learning packets (though with 0 tag)
The fix is by denying the addition/removal of vlan 0 through the ndo_vlan
functions and do it ourselves in the bond's netdev event handler when a
vlan 0 is added/removed from a bonding device. Also a small comment fix
which adds the missing proto parameter.

Patch 02 - switches the bonding to the now standard vlan syncing functions
vlan_vids_add/del_by_dev() and removes the bonding specific ones.

Patch 03 - reverts vlan addition in case of bond_add_vlan failure because
otherwise we may get bad vlan refcounts in the slaves.

Best regards,
 Nikolay Aleksandrov

Nikolay Aleksandrov (3):
  bonding: fix vlan 0 addition and removal
  bonding: change the bond's vlan syncing functions with the standard
    ones
  bonding: unwind on bond_add_vlan add failure

 drivers/net/bonding/bond_main.c | 86 +++++++++++++++++++++++++----------------
 1 file changed, 52 insertions(+), 34 deletions(-)

-- 
1.8.1.4
