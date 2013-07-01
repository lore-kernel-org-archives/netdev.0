From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: appletalk induced soft lockup
Date: Sun, 30 Jun 2013 23:01:30 -0700
Message-ID: <1372658490.3301.311.camel@edumazet-glaptop>
References: <20130630234252.GB4325@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@ghostprotocols.net
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f172.google.com ([209.85.215.172]:38388 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751880Ab3GAGBT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 02:01:19 -0400
Received: by mail-ea0-f172.google.com with SMTP id q10so1845990eaj.3
        for <netdev@vger.kernel.org>; Sun, 30 Jun 2013 23:01:18 -0700 (PDT)
In-Reply-To: <20130630234252.GB4325@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-06-30 at 19:42 -0400, Dave Jones wrote:
> is atalk even maintained any more ? If not I'll take it out of my testing.
> Arnaldo is listed as its maintainer, but I'm sure he has more interesting things
> to work on these days :)
> 
> 	Dave


Could you try following fix ?

Thanks

diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index ef12839..279a287 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1638,9 +1638,7 @@ static int atalk_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr
 			sk, size, dev->name);
 
 	size += dev->hard_header_len;
-	release_sock(sk);
 	skb = sock_alloc_send_skb(sk, size, (flags & MSG_DONTWAIT), &err);
-	lock_sock(sk);
 	if (!skb)
 		goto out;
 
