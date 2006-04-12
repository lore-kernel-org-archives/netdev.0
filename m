From: Zach Brown <zach.brown@oracle.com>
Subject: Re: [RFC][PATCH] Avoid multi-page allocs for large mtu datagram sends
Date: Wed, 12 Apr 2006 11:22:58 -0700
Message-ID: <443D4582.5000301@oracle.com>
References: <20060405175102.GA28166@tetsuo.zabbo.net> <20060412162035.GA18572@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010809050601060904080906"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:35450 "EHLO
	agminet01.oracle.com") by vger.kernel.org with ESMTP
	id S932316AbWDLSYH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Apr 2006 14:24:07 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060412162035.GA18572@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010809050601060904080906
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:
> On Wed, Apr 05, 2006 at 05:51:02PM +0000, Zach Brown wrote:
>> 2) I changed the final-frag test to be length + fraggap as the math later on
>>    seemed to match that.. is that OK?
> 
> Yes that's a real bug introduced by a previous rework.  Could you
> please split that off into a separate patch?

Sure, here it is by itself.  I lightly tested this but didn't actually
use anything that has a non-zero trailer len, I don't think.

Did you have an opinion of the rest of the original patch?

- z



--------------010809050601060904080906
Content-Type: text/x-patch;
 name="ip-append-data-fraggap-math-0.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ip-append-data-fraggap-math-0.patch"


[PATCH] ip_output: account for fraggap when checking to add trailer_len

During other work I noticed that ip_append_data() seemed to be forgetting to
include the frag gap in its calculation of a fragment that consumes the rest of
the payload.  Herbert confirmed that this was a bug that snuck in during a
previous rework.

Signed-off-by: Zach Brown <zach.brown@oracle.com>

Index: 2.6.17-rc1-mm2-fraggap/net/ipv4/ip_output.c
===================================================================
--- 2.6.17-rc1-mm2-fraggap.orig/net/ipv4/ip_output.c
+++ 2.6.17-rc1-mm2-fraggap/net/ipv4/ip_output.c
@@ -904,7 +904,7 @@ alloc_new_skb:
 			 * because we have no idea what fragment will be
 			 * the last.
 			 */
-			if (datalen == length)
+			if (datalen == length + fraggap)
 				alloclen += rt->u.dst.trailer_len;
 
 			if (transhdrlen) {

--------------010809050601060904080906--
