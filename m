From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix limited slow start bug
Date: Thu, 22 Feb 2007 22:53:38 -0800 (PST)
Message-ID: <20070222.225338.59657775.davem@davemloft.net>
References: <45DDE756.20001@psc.edu>
	<Pine.LNX.4.64.0702222317000.29273@kivilampi-30.cs.helsinki.fi>
	<45DE1083.6040900@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55356
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751894AbXBWGxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Feb 2007 01:53:39 -0500
In-Reply-To: <45DE1083.6040900@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Thu, 22 Feb 2007 16:52:03 -0500

> I think it's not unreasonable to change clamp to 32 bits now, since with 
> 1500 byte packets, this corresponds to a max cwnd of ~94MB.  This is 
> pretty big, but we are currently right at this limit with 10 GigE.

Agreed, and done in tcp-2.6.git as below.

What should we do about that 65535 assignment in hybla?

commit cedfa95566512730202bb4abed5d9118e74bab30
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Thu Feb 22 22:52:59 2007 -0800

    [TCP]: Make snd_cwnd_clamp a u32.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 415193e..18a468d 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -302,7 +302,7 @@ struct tcp_sock {
  	u32	snd_ssthresh;	/* Slow start size threshold		*/
  	u32	snd_cwnd;	/* Sending congestion window		*/
  	u16	snd_cwnd_cnt;	/* Linear increase counter		*/
-	u16	snd_cwnd_clamp; /* Do not allow snd_cwnd to grow above this */
+	u32	snd_cwnd_clamp; /* Do not allow snd_cwnd to grow above this */
 	u32	snd_cwnd_used;
 	u32	snd_cwnd_stamp;
 
