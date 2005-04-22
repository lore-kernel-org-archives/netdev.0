From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH][SCTP] Replace incorrect use of dev_alloc_skb with alloc_skb
 in sctp_packet_transmit().
Date: Fri, 22 Apr 2005 12:29:09 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0504221219010.5192@dyn9047018105.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

Please apply to 2.6.

Thanks
Sridhar

===========================================================================
[SCTP] Replace incorrect use of dev_alloc_skb with alloc_skb in
        sctp_packet_transmit().

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
===========================================================================
diff -Nru a/net/sctp/output.c b/net/sctp/output.c
--- a/net/sctp/output.c	2005-04-21 16:25:54 -07:00
+++ b/net/sctp/output.c	2005-04-21 16:25:54 -07:00
@@ -313,12 +313,12 @@
  	sk = chunk->skb->sk;

  	/* Allocate the new skb.  */
-	nskb = dev_alloc_skb(packet->size);
+	nskb = alloc_skb(packet->size + LL_MAX_HEADER, GFP_ATOMIC);
  	if (!nskb)
  		goto nomem;

  	/* Make sure the outbound skb has enough header room reserved. */
-	skb_reserve(nskb, packet->overhead);
+	skb_reserve(nskb, packet->overhead + LL_MAX_HEADER);

  	/* Set the owning socket so that we know where to get the
  	 * destination IP address.

-- 
