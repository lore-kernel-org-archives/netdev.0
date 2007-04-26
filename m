From: Chuck Ebbert <cebbert@redhat.com>
Subject: IPV6 source routing patch is still broken?
Date: Thu, 26 Apr 2007 17:53:58 -0400
Message-ID: <46311F76.9040803@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60928 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755062AbXDZVyE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 17:54:04 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Looking at the patch that went into 2.6.20.9, I can't see
how type 2 packets get through at all. Shouldn't this part
read:

+       case IPV6_SRCRT_TYPE_2:
+               if (accept_source_route >= 0)
+                       break;
+               kfree_skb(skb);
+               return -1;
+       case IPV6_SRCRT_TYPE_0:
+               if (accept_source_route > 0)
+                       break;
+               kfree_skb(skb);
+               return -1;

And what does this do?

+	switch (hdr->type) {
+#ifdef CONFIG_IPV6_MIP6
+		break;
+#endif

break by itself like that doesn't do anything. If it did
then people with mobile ipv6 enabled would always accept all
source routing. (They should at least know that's a problem.)

