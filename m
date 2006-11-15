From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCHv2 1/2]: [NET]: Supporting UDP-Lite (RFC 3828) in Linux
Date: Wed, 15 Nov 2006 07:58:17 +0000
Message-ID: <200611150758.17769@strip-the-willow>
References: <200611140848.45863@strip-the-willow> <20061114.201959.112851807.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:33181 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S966672AbWKOH6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Nov 2006 02:58:21 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061114.201959.112851807.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

|  > [NET]:  Supporting UDP-Lite (RFC 3828) in Linux
| applied to net-2.6.20, thanks Gerrit.
Many thanks indeed. During these changes I accidentally
forgot to restore udp_push_pending_frames to its static state.

Can you please consider the attached patch --


[NET/IPv4]: Make udp_push_pending_frames static
            udp_push_pending_frames is only referenced within
            net/ipv4/udp.c and hence can remain static.

Signed-off-by: Gerrit Renker  <gerrit@erg.abdn.ac.uk>
---

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 227655c..ac613ed 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -447,7 +447,7 @@ static void udp4_hwcsum_outgoing(struct 
 /*
  * Push out all pending data as one UDP datagram. Socket is locked.
  */
-int udp_push_pending_frames(struct sock *sk, struct udp_sock *up)
+static int udp_push_pending_frames(struct sock *sk, struct udp_sock *up)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct flowi *fl = &inet->cork.fl;
