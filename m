From: Antonio Quartulli <antonio@meshcoding.com>
Subject: pull request net: 2013-10-02
Date: Wed,  2 Oct 2013 22:03:20 +0200
Message-ID: <1380744201-2074-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([178.209.62.154]:37379 "EHLO
	s2.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754094Ab3JBUEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 16:04:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is a "one-change" pull request intended for net/linux-3.{12,11,10}.

This patch from Matthias Schiffer is fixing the init routine of the Network
Coding component by preventing it from registering the handler for the CODED
packet type each time a new soft-interface is created.

Without this fix a second soft-interface cannot be created unless the Network
Coding component is not part of the module (not compiled-in).

As I mentioned before, this fix should be queued for stable as it aims
kernels older than linux-3.12.

Please pull or let me know of any problem.
Thanks a lot,
	Antonio


p.s. this change generates some non-negligible conflicts with the patchset I'd
like to send to net-next during this week. Since I'd like to solve them all by
myself before sending the new patches, I'd kindly ask you to merge net into
net-next when possible.


The following changes since commit c31eeaced22ce8bd61268a3c595d542bb38c0a4f:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2013-10-01 12:58:48 -0700)

are available in the git repository at:


  git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

for you to fetch changes up to 6c519bad7b19a2c14a075b400edabaa630330123:

  batman-adv: set up network coding packet handlers during module init (2013-10-02 13:46:19 +0200)

----------------------------------------------------------------
Included change:
- fix multi soft-interfaces setups with Network Coding enabled by
  registering the CODED packet type once only (instead of once per soft-if)

----------------------------------------------------------------
Matthias Schiffer (1):
      batman-adv: set up network coding packet handlers during module init

 net/batman-adv/main.c           |  5 +++--
 net/batman-adv/network-coding.c | 28 ++++++++++++++++++----------
 net/batman-adv/network-coding.h | 14 ++++++++++----
 3 files changed, 31 insertions(+), 16 deletions(-)
