From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Scalability of interface creation and deletion
Date: Sat, 07 May 2011 20:39:13 +0200
Message-ID: <1304793553.3207.24.camel@edumazet-laptop>
References: <891B02256A0667292521A4BF@Ximines.local>
	 <1304770926.2821.1157.camel@edumazet-laptop>
	 <0F4A638C2A523577CDBC295E@Ximines.local>
	 <1304785589.3207.5.camel@edumazet-laptop>
	 <178E8895FB84C07251538EF7@Ximines.local>
	 <1304793174.3207.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Alex Bligh <alex@alex.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48496 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755901Ab1EGSjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 14:39:17 -0400
Received: by wya21 with SMTP id 21so3070386wya.19
        for <netdev@vger.kernel.org>; Sat, 07 May 2011 11:39:15 -0700 (PDT)
In-Reply-To: <1304793174.3207.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 07 mai 2011 =C3=A0 20:32 +0200, Eric Dumazet a =C3=A9crit :

Also you could patch synchronize_sched() itself instead of
synchronize_net()

diff --git a/kernel/rcutree.c b/kernel/rcutree.c
index dd4aea8..4af6e10 100644
--- a/kernel/rcutree.c
+++ b/kernel/rcutree.c
@@ -1518,6 +1518,7 @@ EXPORT_SYMBOL_GPL(call_rcu_bh);
 void synchronize_sched(void)
 {
 	struct rcu_synchronize rcu;
+	ktime_t time_start =3D ktime_get();
=20
 	if (rcu_blocking_is_gp())
 		return;
@@ -1529,6 +1530,7 @@ void synchronize_sched(void)
 	/* Wait for it. */
 	wait_for_completion(&rcu.completion);
 	destroy_rcu_head_on_stack(&rcu.head);
+	pr_err("synchronize_rcu() in %lld us\n", ktime_us_delta(ktime_get(), =
time_start));
 }
 EXPORT_SYMBOL_GPL(synchronize_sched);
=20


