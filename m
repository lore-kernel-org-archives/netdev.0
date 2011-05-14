From: Sven Eckelmann <sven@narfation.org>
Subject: pull request: batman-adv 2011-05-14
Date: Sun, 15 May 2011 00:16:32 +0200
Message-ID: <1305411394-28807-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:45195 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754919Ab1ENWQo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 May 2011 18:16:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I would like tp propose following corrections for net-next-2.6/2.6.40.
Both are bug fixes. The first one fixes the regression introduced by
"batman-adv: Make bat_priv->primary_if an rcu protected pointer" which
prevented that the attached net_devices could be destroyed because the
references to them were incorrectly counted.

The second one is a bug which may "filled" the broadcast queue when at
the same time primary_if got changed and a broadcast was initiated. The
queue counter were never reduced because there were no actual packets
attached to the the queue.

thanks,
	Sven


The following changes since commit 27aea2128ec09924dfe08e97739b2bf8b15c8619:

  batman-adv: remove duplicate code from function is_bidirectional_neigh() (2011-05-08 16:10:42 +0200)

are available in the git repository at:
  git://git.open-mesh.org/ecsv/linux-merge.git batman-adv/next

Marek Lindner (1):
      batman-adv: reset broadcast flood protection on error

Sven Eckelmann (1):
      batman-adv: Add missing hardif_free_ref in forw_packet_free

 net/batman-adv/aggregation.c |   14 +++++++++++---
 net/batman-adv/send.c        |   19 ++++++++++++++++---
 2 files changed, 27 insertions(+), 6 deletions(-)
