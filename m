From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: [PATCH net-next-2.6] Re: TCP/IP stack interpretation of
	acceptable packet
Date: Mon, 23 Mar 2009 10:13:31 -0500
Message-ID: <1237821211.7142.17.camel@Maple>
References: <2ff60cd60902241459q1de39054lb3dc5233f13b69c3@mail.gmail.com>
	 <1237423493.32009.31.camel@Maple>
	 <20090322.215033.192091282.davem@davemloft.net>
	 <20090323122806.GA11935@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	mailinglists+netdev@oliverzheng.com, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.239]:22626 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757010AbZCWPNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 11:13:36 -0400
Received: by rv-out-0506.google.com with SMTP id f9so1810723rvb.1
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2009 08:13:35 -0700 (PDT)
In-Reply-To: <20090323122806.GA11935@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-03-22 at 21:50 -0700, David Miller wrote:
> I've been mulling over this patch for more than a week :-)

FWIW, FreeBSD 6.1 discards segments with these over-eager acknowledgment
fields.  It also sends back the pure ACK that I chose not to add.  

I didn't look at any other OS's.

On Mon, 2009-03-23 at 13:28 +0100, Andi Kleen wrote:
> One thing that might be useful for the testing period would 
> be explicit printk when such a new discard happens? 

[PATCH net-next-2.6]  tcp: Log discarded segments with too-high ack fields

Log a rate-limited message when a TCP segment is discarded because
its ack field is beyond the last data sent.  This logging was suggested
by Andi Kleen.

Signed-off-by: John Dykstra <john.dykstra1@gmail.com>
---
 net/ipv4/tcp_input.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 01544cd..37343e4 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3690,7 +3690,9 @@ no_queue:
 	return 1;
 
 invalid_ack:
-	SOCK_DEBUG(sk, "Ack %u after %u:%u\n", ack, tp->snd_una, tp->snd_nxt);
+	if (printk_ratelimit())
+		printk(KERN_NOTICE "Ack %u after %u:%u;  segment discarded\n",
+		    ack, tp->snd_una, tp->snd_nxt);
 	return -1;
 	
 old_ack:
-- 
1.5.4.3



