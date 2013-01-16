From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: [PATCH] ipv6: do not create neighbor entries for local delivery
Date: Wed, 16 Jan 2013 11:31:54 -0200
Message-ID: <50F6ABCA.4020804@redhat.com>
Reply-To: mleitner@redhat.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030204010203070106090003"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8631 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753252Ab3APNb4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 08:31:56 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r0GDVu0B011745
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 16 Jan 2013 08:31:56 -0500
Received: from localhost.localdomain (vpn1-7-82.gru2.redhat.com [10.97.7.82])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id r0GDVtll012117
	for <netdev@vger.kernel.org>; Wed, 16 Jan 2013 08:31:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030204010203070106090003
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

They will be created at output, if ever needed. This avoids creating
empty neighbor entries when TPROXYing/Forwarding packets for addresses
that are not even directly reachable.

Note that IPv4 already handles it this way. No neighbor entries are
created for local input.

Tested by myself and customer.

Signed-off-By: Marcelo Ricardo Leitner <mleitner@redhat.com>
---
  net/ipv6/route.c | 2 +-
  1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 
7c34c01b515b7ac370f8021ba6f5ec4c654e9e41..b63e33bcbdfbc1bd78af0b98ffc2d211805214ea 
100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -921,7 +921,7 @@ restart:
  	dst_hold(&rt->dst);
  	read_unlock_bh(&table->tb6_lock);
-	if (!rt->n && !(rt->rt6i_flags & RTF_NONEXTHOP))
+	if (!rt->n && !(rt->rt6i_flags & (RTF_NONEXTHOP|RTF_LOCAL)))
  		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
  	else if (!(rt->dst.flags & DST_HOST))
  		nrt = rt6_alloc_clone(rt, &fl6->daddr);
-- 
1.7.11.7


--------------030204010203070106090003
Content-Type: text/plain; charset=UTF-8;
 name="=?UTF-8?B?U2XDp8OjbyBkYSBtZW5zYWdlbSBhbmV4YWRh?="
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename*0*=UTF-8''%53%65%C3%A7%C3%A3%6F%20%64%61%20%6D%65%6E%73%61%67%65;
 filename*1*=%6D%20%61%6E%65%78%61%64%61


--------------030204010203070106090003--
