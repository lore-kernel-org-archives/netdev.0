From: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
Subject: [PATCH] [IPv6] [trivial] convert to mod_timer
Date: Tue, 18 Mar 2008 13:42:35 +0100
Message-ID: <20080318124235.GB6977@ens-lyon.fr>
References: <20080318124008.GA6977@ens-lyon.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pilet.ens-lyon.fr ([140.77.167.16]:40384 "EHLO
	pilet.ens-lyon.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752655AbYCRNRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2008 09:17:21 -0400
Content-Disposition: inline
In-Reply-To: <20080318124008.GA6977@ens-lyon.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert addrconf_verify to mod_timer

Signed-off-by: Benoit Boissinot <benoit.boissinot@ens-lyon.org>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 101e0e7..5d0e404 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2922,8 +2943,6 @@ static void addrconf_verify(unsigned long foo)
        now = jiffies;
        next = now + ADDR_CHECK_FREQUENCY;

-       del_timer(&addr_chk_timer);
-
        for (i=0; i < IN6_ADDR_HSIZE; i++) {

 restart:
@@ -3013,8 +3032,7 @@ restart:
                read_unlock(&addrconf_hash_lock);
        }

-       addr_chk_timer.expires = time_before(next, jiffies + HZ) ? jiffies + HZ : next;
-       add_timer(&addr_chk_timer);
+       mod_timer(&addr_chk_timer, time_before(next, jiffies + HZ) ? jiffies + HZ : next);
        spin_unlock_bh(&addrconf_verify_lock);
 }


-- 
:wq
