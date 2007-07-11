From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NET]: Update comments for skb checksums
Date: Wed, 11 Jul 2007 09:33:53 +0800
Message-ID: <20070711013353.GA6082@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2003 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754207AbXGKBeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 21:34:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

[NET]: Update comments for skb checksums

Rusty (whose comments we should all study and emulate :) pointed
out that our comments for skb checksums are no longer up-to-date.
So here is a patch to

1) add the case of partial checksums on input;
2) update partial checksum case to mention csum_start/csum_offset;
3) mention the new IPv6 feature bit.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -65,13 +65,20 @@
  *	    is able to produce some skb->csum, it MUST use COMPLETE,
  *	    not UNNECESSARY.
  *
+ *	PARTIAL: identical to the case for output below.  This may occur
+ *	    on a packet received directly from another Linux OS, e.g.,
+ *	    a virtualised Linux kernel on the same host.  The packet can
+ *	    be treated in the same way as UNNECESSARY except that on
+ *	    output (i.e., forwarding) the checksum must be filled in
+ *	    by the OS or the hardware.
+ *
  * B. Checksumming on output.
  *
  *	NONE: skb is checksummed by protocol or csum is not required.
  *
  *	PARTIAL: device is required to csum packet as seen by hard_start_xmit
- *	from skb->transport_header to the end and to record the checksum
- *	at skb->transport_header + skb->csum.
+ *	from skb->csum_start to the end and to record the checksum
+ *	at skb->csum_start + skb->csum_offset.
  *
  *	Device must show its capabilities in dev->features, set
  *	at device setup time.
@@ -82,6 +89,7 @@
  *			  TCP/UDP over IPv4. Sigh. Vendors like this
  *			  way by an unknown reason. Though, see comment above
  *			  about CHECKSUM_UNNECESSARY. 8)
+ *	NETIF_F_IPV6_CSUM about as dumb as the last one but does IPv6 instead.
  *
  *	Any questions? No questions, good. 		--ANK
  */
