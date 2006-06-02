From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.17-rc4: netfilter LOG messages truncated via NETCONSOLE (2)
Date: Fri, 02 Jun 2006 16:16:08 +0200
Message-ID: <44804828.2050909@trash.net>
References: <20060531094626.GA23156@janus> <447DAEC9.3050003@trash.net> <20060531160611.GA25637@janus> <447DC613.10102@trash.net> <20060531172936.GB25788@janus> <447DD66C.30605@trash.net> <20060601091124.GA31642@janus> <447F2537.1080807@trash.net> <20060602123559.GA7505@janus> <20060602140212.GA7881@janus>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050300050505090900060408"
Cc: linux-kernel@vger.kernel.org,
	Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:25333 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932130AbWFBOQK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jun 2006 10:16:10 -0400
To: Frank van Maarseveen <frankvm@frankvm.com>
In-Reply-To: <20060602140212.GA7881@janus>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050300050505090900060408
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Frank van Maarseveen wrote:
> The 2.6.13.2 data is inconsistent. The bug appears to be present there at
> well after closer examination. So there must be another factor involved
> because I have at least one case logged where 2.6.13.2 did work (the
> "sirkka" log in my previous mail). Applying your patch on 2.6.13.2
> again removes the protocol is buggy messages (when doing a tcpdump)
> but the problem of the 10 missing packets persists.

Which network driver are you using? Does this patch show anything in
the ringbuffer?


--------------050300050505090900060408
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index e8e05ce..2b12280 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -302,6 +302,9 @@ static void netpoll_send_skb(struct netp
 		netpoll_poll(np);
 		udelay(50);
 	} while (npinfo->tries > 0);
+
+	printk("failed to transmit\n");
+	kfree_skb(skb);
 }
 
 void netpoll_send_udp(struct netpoll *np, const char *msg, int len)

--------------050300050505090900060408--
