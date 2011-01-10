From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [PATCH] UDPCP Communication Protocol
Date: Mon, 10 Jan 2011 23:53:17 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1101102352010.32164@swampdragon.chaosbits.net>
References: <1293787785-3834-1-git-send-email-stefani@seibold.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: stefani@seibold.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:16240 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755069Ab1AJWxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 17:53:18 -0500
In-Reply-To: <1293787785-3834-1-git-send-email-stefani@seibold.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


stefani@seibold.net wrote:
+static int udpcp_xmit(struct sock *sk, struct udpcp_dest *dest)
+{
+       struct udpcp_sock *usk = udpcp_sk(sk);
+       int ret;
+
+       ret = _udpcp_xmit(sk, dest);
+
+       if (dest->xmit_wait) {
+               dest->tx_time = jiffies;
+
+               if (!timer_pending(&usk->timer))
+                       udpcp_timer(sk, dest->tx_time + usk->tx_timeout);
+       }
+       return ret;
+}

Wouldn't this be slightly nicer as 

static int udpcp_xmit(struct sock *sk, struct udpcp_dest *dest)
{
       int ret = _udpcp_xmit(sk, dest);

       if (dest->xmit_wait) {
               struct udpcp_sock *usk = udpcp_sk(sk);
               dest->tx_time = jiffies;
               if (!timer_pending(&usk->timer))
                       udpcp_timer(sk, dest->tx_time + usk->tx_timeout);
       }
       return ret;
}

??

-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

