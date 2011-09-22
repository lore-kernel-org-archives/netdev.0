From: Marek Lindner <lindner_marek@yahoo.de>
Subject: pull request: batman-adv 2011-09-22 (regression fix)
Date: Thu, 22 Sep 2011 20:57:15 +0200
Message-ID: <1316717836-19374-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm8.bullet.mail.ukl.yahoo.com ([217.146.182.249]:26282 "HELO
	nm8.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751370Ab1IVS5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2011 14:57:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

our testers have discovered a regression in the current linux-3.1
code base. It increases latency of payload traffic by a factor of
4-5. Therefore we propose a patch that hopefully can be included 
before linux 3.1 final has been released. We kept it as short as 
possible to avoid introducing last minute bugs.

Once you pulled the patch you will run into a merge conflict
with net-next:
++<<<<<<< HEAD
 + orig_node = transtable_search(bat_priv, ethhdr->h_source,
 +                               ethhdr->h_dest);
 + if (is_multicast_ether_addr(ethhdr->h_dest) ||
 + (orig_node && orig_node->gw_flags)) {
++=======
+ orig_node = transtable_search(bat_priv, ethhdr->h_dest);
+ do_bcast = is_multicast_ether_addr(ethhdr->h_dest);
+ if (do_bcast || (orig_node && orig_node->gw_flags)) {
++>>>>>>> batman-adv/maint

The correct merge result would be:
+======
orig_node = transtable_search(bat_priv, ethhdr->h_source,
                              ethhdr->h_dest);
do_bcast = is_multicast_ether_addr(ethhdr->h_dest);
if (do_bcast || (orig_node && orig_node->gw_flags)) {
+======

Let me know if there is a better way to address the merge conflict.

Thanks,
Marek

The following changes since commit 322a8b034003c0d46d39af85bf24fee27b902f48:

  Linux 3.1-rc1 (2011-08-07 18:23:30 -0700)

are available in the git repository at:
  git://git.open-mesh.org/linux-merge.git batman-adv/maint

Antonio Quartulli (1):
      batman-adv: do_bcast has to be true for broadcast packets only

 net/batman-adv/soft-interface.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)
