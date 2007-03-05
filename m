From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] twcal_jiffie should be unsigned long, not int
Date: Mon, 5 Mar 2007 16:09:21 +0100
Message-ID: <200703051609.21133.dada1@cosmosbay.com>
References: <45EBFD13.1060106@symas.com> <200703051528.02564.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_hKD7Fr98X0I7KNk"
Cc: Arnaldo Carvalho de Melo <acme@mandriva.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:54031 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933510AbXCEPJZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 10:09:25 -0500
In-Reply-To: <200703051528.02564.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_hKD7Fr98X0I7KNk
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi David

While browsing include/net/inet_timewait_sock.h, I found this buggy definition 
of twcal_jiffie.

int         twcal_jiffie;

I wonder how inet_twdr_twcal_tick() can really works on x86_64

This seems quite an old bug, it was there before introduction of 
inet_timewait_death_row made by Arnaldo Carvalho de Melo.

[PATCH] twcal_jiffie should be unsigned long, not int

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--Boundary-00=_hKD7Fr98X0I7KNk
Content-Type: text/plain;
  charset="iso-8859-1";
  name="twcal_jiffie.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="twcal_jiffie.patch"

diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index f7be1ac..09a2532 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -66,7 +66,7 @@ #define INET_TWDR_TWKILL_QUOTA 100
 struct inet_timewait_death_row {
 	/* Short-time timewait calendar */
 	int			twcal_hand;
-	int			twcal_jiffie;
+	unsigned long		twcal_jiffie;
 	struct timer_list	twcal_timer;
 	struct hlist_head	twcal_row[INET_TWDR_RECYCLE_SLOTS];
 

--Boundary-00=_hKD7Fr98X0I7KNk--
