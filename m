From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: openconnect triggers soft lockup in __skb_get_rxhash
Date: Sun, 16 Dec 2012 20:46:29 -0800
Message-ID: <1355719589.10504.13.camel@edumazet-glaptop>
References: <20121217005616.GA23029@shutemov.name>
	 <20121216.172214.687979484434537200.davem@davemloft.net>
	 <20121217014631.GA23101@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, maxk@qti.qualcomm.com,
	netdev@vger.kernel.org, dwmw2@infradead.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:60388 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751266Ab2LQEqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2012 23:46:33 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so2583962dak.19
        for <netdev@vger.kernel.org>; Sun, 16 Dec 2012 20:46:32 -0800 (PST)
In-Reply-To: <20121217014631.GA23101@shutemov.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-12-17 at 03:46 +0200, Kirill A. Shutemov wrote:
> On Sun, Dec 16, 2012 at 05:22:14PM -0800, David Miller wrote:
> > 
> > Already fixed in Linus's tree by:
> > 
> > From 499744209b2cbca66c42119226e5470da3bb7040 Mon Sep 17 00:00:00 2001
> 
> No, it's not. I use up-to-date (2a74dbb) Linus tree with the patch in and
> still see the issue.
> 

Coud you try the following one liner ?

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 255a9f5..173acf5 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1199,6 +1199,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 		skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
 	}
 
+	skb_reset_network_header(skb);
 	rxhash = skb_get_rxhash(skb);
 	netif_rx_ni(skb);
 
