From: Antonio Quartulli <ordex@autistici.org>
Subject: pull request: batman-adv 2013-08-28
Date: Wed, 28 Aug 2013 13:28:07 +0200
Message-ID: <1377689291-2412-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:54795 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753508Ab3H1Lc0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 07:32:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

here is a small pull request intended for net-next/linux-3.12.

In this batch you have two really minor things (code rearranging and version
increment) and two behavioural changes:
1) the 'protocol' field of outgoing SKBs is now set according to the type of
   the payload that batman-adv is going to encapsulate;
2) a uevent is now sent when a node exits the "GW client" mode. This is done in
   order to tell userspace that a remote "GW server" is not available anymore.

Please pull or let me know of any problem!

Thanks a lot,
	Antonio

The following changes since commit 5b2941b18dc5f60a5c14a5c15693f9c58b0dd922:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/jesse/openvswitch (2013-08-27 22:11:18 -0400)

are available in the git repository at:


  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to c6eaa3f067d6f9fa55fd9645e93ed79411bebdaf:

  batman-adv: send GW_DEL event when the gw client mode is deselected (2013-08-28 11:33:00 +0200)

----------------------------------------------------------------
Included changes:
- set the protocol field in the skb structure according to the encapsulated
  payload
- make the gateway component send a uevent in case of "gw client mode"
  de-selection
- increment version number
- minor code rearrangement

----------------------------------------------------------------
Antonio Quartulli (2):
      batman-adv: move enum definition at the top of the file
      batman-adv: send GW_DEL event when the gw client mode is deselected

Simon Wunderlich (2):
      batman-adv: set skb priority according to content
      batman-adv: Start new development cycle

 net/batman-adv/bat_iv_ogm.c        | 32 +++++++++++----------
 net/batman-adv/gateway_client.c    | 27 ++++++++++++++++++
 net/batman-adv/gateway_client.h    |  1 +
 net/batman-adv/icmp_socket.c       |  1 +
 net/batman-adv/main.c              | 58 ++++++++++++++++++++++++++++++++++++++
 net/batman-adv/main.h              |  3 +-
 net/batman-adv/routing.c           | 20 ++++++++++++-
 net/batman-adv/send.c              |  1 -
 net/batman-adv/soft-interface.c    |  2 ++
 net/batman-adv/sysfs.c             |  4 +++
 net/batman-adv/translation-table.c |  5 ++++
 net/batman-adv/unicast.c           |  2 ++
 net/batman-adv/vis.c               |  2 ++
 13 files changed, 140 insertions(+), 18 deletions(-)
