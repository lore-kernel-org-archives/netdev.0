From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] net-next: ipv6: ndisc: allocate a ndisc socket per
 inet6_dev
Date: Mon, 25 Jun 2012 14:02:37 +0200
Message-ID: <1340625757.10893.40.camel@edumazet-glaptop>
References: <D8C50530D6022F40A817A35C40CC06A70B34E34D44@DUBX7MCDUB01.EMEA.DELL.COM>
	 <1340620878.10893.26.camel@edumazet-glaptop>
	 <D8C50530D6022F40A817A35C40CC06A70B34E34DA7@DUBX7MCDUB01.EMEA.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Menny_Hamburger@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:40005 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752048Ab2FYMCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 08:02:42 -0400
Received: by bkcji2 with SMTP id ji2so3028276bkc.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 05:02:41 -0700 (PDT)
In-Reply-To: <D8C50530D6022F40A817A35C40CC06A70B34E34DA7@DUBX7MCDUB01.EMEA.DELL.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-25 at 12:08 +0100, Menny_Hamburger@Dell.com wrote:
> I'm sorry for not responding on your post.

...

> I really want to understand how this fixes our problem.
> This fix will make the skb allocations succeed, but what mechanism releases the stuck socket associated with the bad device?

There is no stuck socket, I don't know why you believe this.

And I don't want to spend time writing a changelog if the patch doesn't
solve the problem, especially knowing you didn't even test it.

net/ipv4/arp.c arp_create() doesn't use a 'global socket' to attach skbs
on a socket.

This kind of protection makes sense for UDP / ICMP sockets, not for ARP
or ND resolution.

If you don't understand my patch, don't post your own, thats really lost
time for everyone.

We don't want adding yet another per device stuff for ipv6.
We already have too big memory footprint.

Once I am sure patch fixes the problem, I'll make an official submission
with all credits and changelog.
