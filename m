From: Herton Ronaldo Krzesinski <herton.krzesinski@canonical.com>
Subject: [ 3.5.y.z extended stable ] Patch "batman-adv: fix random jitter calculation" has been added to staging queue
Date: Mon, 14 Jan 2013 18:58:01 -0200
Message-ID: <1358197081-17648-1-git-send-email-herton.krzesinski@canonical.com>
Cc: Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	b.a.t.m.a.n@lists.open-mesh.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Herton Ronaldo Krzesinski <herton.krzesinski@canonical.com>,
	kernel-team@lists.ubuntu.com
To: Akinobu Mita <akinobu.mita@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:53871 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757950Ab3ANU6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 15:58:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a note to let you know that I have just added a patch titled

    batman-adv: fix random jitter calculation

to the linux-3.5.y-queue branch of the 3.5.y.z extended stable tree 
which can be found at:

 http://kernel.ubuntu.com/git?p=ubuntu/linux.git;a=shortlog;h=refs/heads/linux-3.5.y-queue

If you, or anyone else, feels it should not be added to this tree, please 
reply to this email.

For more information about the 3.5.y.z tree, see
https://wiki.ubuntu.com/Kernel/Dev/ExtendedStable

Thanks.
-Herton

------

>From 12a62234843bc692176f3dc51492cfe84156f1c4 Mon Sep 17 00:00:00 2001
From: Akinobu Mita <akinobu.mita@gmail.com>
Date: Wed, 26 Dec 2012 02:32:10 +0000
Subject: [PATCH] batman-adv: fix random jitter calculation

commit 143cdd8f33909ff5a153e3f02048738c5964ba26 upstream.

batadv_iv_ogm_emit_send_time() attempts to calculates a random integer
in the range of 'orig_interval +- BATADV_JITTER' by the below lines.

        msecs = atomic_read(&bat_priv->orig_interval) - BATADV_JITTER;
        msecs += (random32() % 2 * BATADV_JITTER);

But it actually gets 'orig_interval' or 'orig_interval - BATADV_JITTER'
because '%' and '*' have same precedence and associativity is
left-to-right.

This adds the parentheses at the appropriate position so that it matches
original intension.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Acked-by: Antonio Quartulli <ordex@autistici.org>
Cc: Marek Lindner <lindner_marek@yahoo.de>
Cc: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Cc: Antonio Quartulli <ordex@autistici.org>
Cc: b.a.t.m.a.n@lists.open-mesh.org
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Herton Ronaldo Krzesinski <herton.krzesinski@canonical.com>
---
 net/batman-adv/bat_iv_ogm.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index dc53798..bcf3760 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -117,7 +117,7 @@ static unsigned long bat_iv_ogm_emit_send_time(const struct bat_priv *bat_priv)
 {
 	return jiffies + msecs_to_jiffies(
 		   atomic_read(&bat_priv->orig_interval) -
-		   JITTER + (random32() % 2*JITTER));
+		   JITTER + (random32() % (2*JITTER)));
 }

 /* when do we schedule a ogm packet to be sent */
--
1.7.9.5
