From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NULL pointer dereference panic in stable (2.6.33.2), amd64
Date: Thu, 15 Apr 2010 12:37:10 +0200
Message-ID: <1271327830.16881.2370.camel@edumazet-laptop>
References: <1271318553.16881.2161.camel@edumazet-laptop>
	 <1271321507.16881.2244.camel@edumazet-laptop>
	 <20100415.020619.00349859.davem@davemloft.net>
	 <201004151211.28315.nuclearcat@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	netdev@vger.kernel.org
To: Denys Fedorysychenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:48463 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752889Ab0DOKhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 06:37:20 -0400
Received: by bwz25 with SMTP id 25so1353306bwz.28
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 03:37:19 -0700 (PDT)
In-Reply-To: <201004151211.28315.nuclearcat@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 15 avril 2010 =C3=A0 12:11 +0300, Denys Fedorysychenko a =C3=A9=
crit :
> Btw i have application using tun.

Could you add following sanity test to catch the error ?

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index fa8b476..b67274a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -988,6 +988,7 @@ static inline
 struct netdev_queue *netdev_get_tx_queue(const struct net_device *dev,
 					 unsigned int index)
 {
+	WARN_ON(index >=3D dev->num_tx_queues);
 	return &dev->_tx[index];
 }
=20


