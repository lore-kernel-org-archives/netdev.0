From: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
Subject: [PATCH 2 of 5] IPv6: only update the lifetime of the relevant
	temporary address
Date: Sun, 23 Mar 2008 21:46:10 +0100
Message-ID: <5e50b19fbb757f080905.1206305170@pirzuine>
References: <patchbomb.1206305168@pirzuine>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp8-g19.free.fr ([212.27.42.65]:38123 "EHLO smtp8-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752339AbYCWUqP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Mar 2008 16:46:15 -0400
In-Reply-To: <patchbomb.1206305168@pirzuine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6: only update the lifetime of the relevant temporary address

When receiving a prefix information from a routeur, only update the lifetimes
of the temporary address associated with that prefix.
Otherwise if one deprecated prefix is advertized, all your temporary addresses
will become deprecated.

Signed-off-by: Benoit Boissinot <benoit.boissinot@ens-lyon.org>

diff -r dd125a7f8696 -r 5e50b19fbb75 net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	Sat Mar 22 00:50:21 2008 +0100
+++ b/net/ipv6/addrconf.c	Sat Mar 22 00:41:39 2008 +0100
@@ -1832,6 +1832,10 @@
 				 * when processing a Prefix Information Option.
 				 */
 				spin_lock(&ift->lock);
+				if (ifp != ift->ifpub) {
+					spin_unlock(&ift->lock);
+					continue;
+				}
 				flags = ift->flags;
 				if (ift->valid_lft > valid_lft &&
 				    ift->valid_lft - valid_lft > (jiffies - ift->tstamp) / HZ)
