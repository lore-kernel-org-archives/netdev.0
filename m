From: "Stoyan Gaydarov" <stoyboyker@gmail.com>
Subject: [PATCH] round_jiffies in ipv4
Date: Mon, 7 Jul 2008 22:16:53 -0500
Message-ID: <6d291e080807072016h5303b656h4633388db5bfc291@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:44582 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755592AbYGHDQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 23:16:57 -0400
Received: by nf-out-0910.google.com with SMTP id d3so723803nfc.21
        for <netdev@vger.kernel.org>; Mon, 07 Jul 2008 20:16:53 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the timers to use round_jiffies() since they are
used for garbage collection.


Signed-off-by: Stoyan Gaydarov <stoyboyker@gmail.com>

diff -uprN linux-2.6.26-rc9/net/ipv4/ipvs/ip_vs_lblc.c
devel/net/ipv4/ipvs/ip_vs_lblc.c
--- linux-2.6.26-rc9/net/ipv4/ipvs/ip_vs_lblc.c 2008-07-05
17:53:22.000000000 -0500
+++ devel/net/ipv4/ipvs/ip_vs_lblc.c    2008-07-07 22:05:04.000000000 -0500
@@ -364,7 +364,7 @@ static int ip_vs_lblc_init_svc(struct ip
         */
        setup_timer(&tbl->periodic_timer, ip_vs_lblc_check_expire,
                        (unsigned long)tbl);
-       tbl->periodic_timer.expires = jiffies+CHECK_EXPIRE_INTERVAL;
+       tbl->periodic_timer.expires =
round_jiffies(jiffies+CHECK_EXPIRE_INTERVAL);
        add_timer(&tbl->periodic_timer);

        return 0;
diff -uprN linux-2.6.26-rc9/net/ipv4/ipvs/ip_vs_lblcr.c
devel/net/ipv4/ipvs/ip_vs_lblcr.c
--- linux-2.6.26-rc9/net/ipv4/ipvs/ip_vs_lblcr.c        2008-07-05
17:53:22.000000000 -0500
+++ devel/net/ipv4/ipvs/ip_vs_lblcr.c   2008-07-07 22:03:51.000000000 -0500
@@ -548,7 +548,7 @@ static int ip_vs_lblcr_init_svc(struct i
         */
        setup_timer(&tbl->periodic_timer, ip_vs_lblcr_check_expire,
                        (unsigned long)tbl);
-       tbl->periodic_timer.expires = jiffies+CHECK_EXPIRE_INTERVAL;
+       tbl->periodic_timer.expires =
round_jiffies(jiffies+CHECK_EXPIRE_INTERVAL);
        add_timer(&tbl->periodic_timer);

        return 0;
