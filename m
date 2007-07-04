From: Patrick McHardy <kaber@trash.net>
Subject: [NET]: Fix gen_estimator timer removal race
Date: Wed, 04 Jul 2007 17:47:51 +0200
Message-ID: <468BC127.1090904@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070706070107080200040802"
Cc: Jarek Poplawski <jarkao2@o2.pl>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40305 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500AbXGDPsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2007 11:48:07 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070706070107080200040802
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

This is an updated version of the gen_estimator fix
that relies on all changes happening under the rtnl
and just fixes the race between timer rearming and
timer removal.



--------------070706070107080200040802
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET]: Fix gen_estimator timer removal race

As noticed by Jarek Poplawski <jarkao2@o2.pl>, the timer removal in
gen_kill_estimator races with the timer function rearming the timer.

Check whether the timer list is empty before rearming the timer
in the timer function to fix this.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 369edff5c22c6838cb632c24a1971f1ce6823991
tree b0f47f8469ed9fc47e8fc6b597b204aac816133a
parent ba609a9d97ba231c3d94443c50579ceb5fc33867
author Patrick McHardy <kaber@trash.net> Wed, 04 Jul 2007 17:45:26 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 04 Jul 2007 17:45:26 +0200

 net/core/gen_estimator.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index 17daf4c..cc84d8d 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -128,7 +128,8 @@ static void est_timer(unsigned long arg)
 		spin_unlock(e->stats_lock);
 	}
 
-	mod_timer(&elist[idx].timer, jiffies + ((HZ<<idx)/4));
+	if (elist[idx].list != NULL)
+		mod_timer(&elist[idx].timer, jiffies + ((HZ<<idx)/4));
 	read_unlock(&est_lock);
 }
 

--------------070706070107080200040802--
