From: Julian Anastasov <ja@ssi.bg>
Subject: Re: suggestion for routing code improvement
Date: Thu, 11 Apr 2002 18:24:51 +0300 (EEST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0204111813500.5560-100000@l>
References: <15541.41833.773161.740744@robur.slu.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Chris Friesen <cfriesen@nortelnetworks.com>, <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <15541.41833.773161.740744@robur.slu.se>
List-Id: netdev.vger.kernel.org


	Hello,

On Thu, 11 Apr 2002, Robert Olsson wrote:

>  > 	If you use another hash function for the route cache you can
>  > even get better :) In my tests with many hosts i got 8% increase in
>  > performance.
>
>  Interesting. At what rate of new connections/s did you test?

	It was on 100mbit, I already don't remember the exact tests
and number of clients, etc. The patch is archived ..., here it is.
You can try it yourself:


--- net/ipv4/route.c.orig	Wed Jun  6 17:51:49 2001
+++ net/ipv4/route.c	Wed Jun  6 18:25:45 2001
@@ -203,11 +203,9 @@

 static __inline__ unsigned rt_hash_code(u32 daddr, u32 saddr, u8 tos)
 {
-	unsigned hash = ((daddr & 0xF0F0F0F0) >> 4) |
-			((daddr & 0x0F0F0F0F) << 4);
-	hash ^= saddr ^ tos;
-	hash ^= (hash >> 16);
-	return (hash ^ (hash >> 8)) & rt_hash_mask;
+	unsigned hash = (saddr + daddr + tos);
+	hash = ntohl(hash) * 2654435761UL;
+	return hash & rt_hash_mask;
 }

 static int rt_cache_get_info(char *buffer, char **start, off_t offset,



I'm using attacking program with configurable number of client IPs:

http://www.linuxvirtualserver.org/~julian/#testlvs

	Sorry that it does not have flood rate limits, use QoS in
the flooding host :) You can try the patch with different tools,
of course.

>  Cheers	.
>
> 						--ro

Regards

--
Julian Anastasov <ja@ssi.bg>
