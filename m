From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sun, 02 Dec 2012 19:36:05 -0500 (EST)
Message-ID: <20121202.193605.2007066227191552770.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33493 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754045Ab2LCAgG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Dec 2012 19:36:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) 8139cp leaks memory in error paths, from Francois Romieu.

2) do_tcp_sendpages() cannot handle order > 0 pages, but they can
   certainly arrive there now, fix from Eric Dumazet.

3) Race condition and sysfs fixes in bonding from Nikolay Aleksandrov.

4) Remain-on-Channel fix in mac80211 from Felix Liao.

5) CCK rate calculation fix in iwlwifi, from Emmanuel Grumbach.

Please pull, thanks a lot!

The following changes since commit e9296e89b85604862bd9ec2d54dc43edad77=
5c0d:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2012-1=
1-28 21:54:07 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to 892a925e42adb8192a3c832ad29cbc780fc466f6=
:

  8139cp: fix coherent mapping leak in error path. (2012-12-01 20:39:17=
 -0500)

----------------------------------------------------------------
Emmanuel Grumbach (1):
      iwlwifi: fix the basic CCK rates calculation

Eric Dumazet (1):
      tcp: fix crashes in do_tcp_sendpages()

Johannes Berg (1):
      mac80211: fix remain-on-channel (non-)cancelling

John W. Linville (2):
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwi=
fi-fixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

fran=E7ois romieu (1):
      8139cp: fix coherent mapping leak in error path.

nikolay@redhat.com (3):
      bonding: fix miimon and arp_interval delayed work race conditions
      bonding: make arp_ip_target parameter checks consistent with sysf=
s
      bonding: fix race condition in bonding_store_slaves_active

 drivers/net/bonding/bond_main.c         | 93 +++++++++++++++++++++----=
------------------------------------------
 drivers/net/bonding/bond_sysfs.c        | 36 +++++++++----------------=
-
 drivers/net/ethernet/realtek/8139cp.c   | 11 +++++---
 drivers/net/wireless/iwlwifi/dvm/rxon.c | 12 ++++-----
 net/ipv4/tcp.c                          | 15 +++++------
 net/mac80211/offchannel.c               |  2 --
 6 files changed, 61 insertions(+), 108 deletions(-)
