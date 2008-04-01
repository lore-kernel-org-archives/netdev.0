From: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
Subject: [PATCH 1 of 2] IPv6: only update the lifetime of the relevant
	temporary address
Date: Wed, 02 Apr 2008 01:09:00 +0200
Message-ID: <0c33481968e0b6b8efd7.1207091340@pirzuine>
References: <patchbomb.1207091339@pirzuine>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp8-g19.free.fr ([212.27.42.65]:45754 "EHLO smtp8-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752189AbYDAXJC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2008 19:09:02 -0400
In-Reply-To: <patchbomb.1207091339@pirzuine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6: only update the lifetime of the relevant temporary address

When receiving a prefix information from a routeur, only update the lifetimes
of the temporary address associated with that prefix.
Otherwise if one deprecated prefix is advertized, all your temporary addresses
will become deprecated.

Signed-off-by: Benoit Boissinot <benoit.boissinot@ens-lyon.org>

diff -r a3c03e70c69f -r 0c33481968e0 net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	Wed Apr 02 00:45:29 2008 +0200
+++ b/net/ipv6/addrconf.c	Sat Mar 22 00:41:39 2008 +0100
@@ -1831,6 +1831,9 @@
 				 * lifetimes of an existing temporary address
 				 * when processing a Prefix Information Option.
 				 */
+				if (ifp != ift->ifpub)
+					continue;
+
 				spin_lock(&ift->lock);
 				flags = ift->flags;
 				if (ift->valid_lft > valid_lft &&
