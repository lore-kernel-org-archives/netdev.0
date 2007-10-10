From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] division-by-zero in inet_csk_get_port
Date: Wed, 10 Oct 2007 11:04:12 -0400
Message-ID: <470CE9EC.10008@hp.com>
References: <m31wc3l4ym.fsf@bandura.englab.brq.redhat.com>	<20071010.023515.15263796.davem@davemloft.net>	<m3wstvjnso.fsf@bandura.englab.brq.redhat.com>	<20071010.030153.09951294.davem@davemloft.net> <m3sl4jjfsx.fsf@bandura.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090701010809080902040208"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Anton Arapov <aarapov@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:41601 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754443AbXJJPEO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 11:04:14 -0400
In-Reply-To: <m3sl4jjfsx.fsf@bandura.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090701010809080902040208
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Anton Arapov wrote:
>   So, now the way suggested by Denis looks reasonable.
> 
>   What do you think?

If that's the case then you should fix __udp_lib_get_port() the same way.

Prevent division by zero in __udp_lib_get_port() when only one 
unsecured port is available.

-Brian


Signed-off-by: Brian Haley <brian.haley@hp.com>


--------------090701010809080902040208
Content-Type: text/x-patch;
 name="udp_port_range.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="udp_port_range.patch"

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index ef4d901..61faa38 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -150,10 +150,11 @@ int __udp_lib_get_port(struct sock *sk, unsigned short snum,
 		int i;
 		int low = sysctl_local_port_range[0];
 		int high = sysctl_local_port_range[1];
+		int remaining = (high - low) + 1;
 		unsigned rover, best, best_size_so_far;
 
 		best_size_so_far = UINT_MAX;
-		best = rover = net_random() % (high - low) + low;
+		best = rover = net_random() % remaining + low;
 
 		/* 1st pass: look for empty (or shortest) hash chain */
 		for (i = 0; i < UDP_HTABLE_SIZE; i++) {

--------------090701010809080902040208--
