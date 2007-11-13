From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH] netdev: create an "is_napi_enabled()" call
Date: Tue, 13 Nov 2007 17:06:36 -0600
Message-ID: <20071113230636.GJ8421@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@vger.kernel.org>, e1000-devel@lists.sourceforge.net
To: Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:43499 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758678AbXKMXGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 18:06:38 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lADN6bL0021860
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2007 18:06:37 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lADN6bRC129400
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2007 16:06:37 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lADN6aD2027027
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2007 16:06:36 -0700
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


In certain rare cases, it can be nice to be able to check
if napi is enabled or not. Create an is_napi_enabled() call.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
-------
Actually, I'm confused about whether I'd mailed this previously.
It might be a duplicate submission.

 include/linux/netdevice.h |   11 +++++++++++
 1 file changed, 11 insertions(+)

Index: linux-2.6.23-rc8-mm1/include/linux/netdevice.h
===================================================================
--- linux-2.6.23-rc8-mm1.orig/include/linux/netdevice.h	2007-11-09 17:36:51.000000000 -0600
+++ linux-2.6.23-rc8-mm1/include/linux/netdevice.h	2007-11-09 17:40:19.000000000 -0600
@@ -384,6 +384,17 @@ static inline void napi_enable(struct na
 	clear_bit(NAPI_STATE_SCHED, &n->state);
 }
 
+/**
+ *	is_napi_enabled - return non-zero if napi enabled
+ *	@n: napi context
+ *
+ * Return true if napi is enabled.
+ */
+static inline bool is_napi_enabled(struct napi_struct *n)
+{
+	return !test_bit(NAPI_STATE_SCHED, &n->state);
+}
+
 /*
  *	The DEVICE structure.
  *	Actually, this whole structure is a big mistake.  It mixes I/O
