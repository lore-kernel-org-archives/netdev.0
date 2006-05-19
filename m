From: "Daniel J Blueman" <daniel.blueman@gmail.com>
Subject: sky2 large MTU problems...
Date: Fri, 19 May 2006 17:22:42 +0100
Message-ID: <6278d2220605190922v4fd3f947ia4c60f01884731e7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org,
	"Linux Networking" <linux-net@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.235]:1999 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S932380AbWESQWv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 May 2006 12:22:51 -0400
Received: by wr-out-0506.google.com with SMTP id 50so187964wri
        for <netdev@vger.kernel.org>; Fri, 19 May 2006 09:22:51 -0700 (PDT)
To: shemminger@osdl.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've found that when increasing the sky2 interface MTU beyond
somewhere around 6000-7500, packets can get truncated.

The interface is the internal interface on a NAT router - I've been
able to reproduce this with 2.6.16 and 2.6.17-rc4 when say sending an
email from gmail (via the web interface).

Hardware:

sky2 v1.3 addr 0xdfbfc000 irq 169 Yukon-EC (0xb6) rev 1

Symptoms:

# ifconfig lan0 mtu 7500
# tcpdump -ni lan0
08:38:13.595118 IP truncated-ip - 100 bytes missing! 192.168.0.3.1552
> 213.160.98.138.554: . 2700848741:2700850201(1460) ack 1729330122 win
64883

(then sending from gmail hangs)

Let me know if you need a more specific reproducer (eg a particular
URL); I can test changes too.
-- 
Daniel J Blueman
