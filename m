From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] net,socket: introduce build_sockaddr_check helper to
	catch overflow at build time
Date: Sat, 24 Oct 2009 01:43:06 +0400
Message-ID: <20091023214306.GA30616@lenovo>
References: <20091021170732.GE5976@lenovo> <20091022.044914.36401063.davem@davemloft.net> <20091022135557.GA5162@lenovo>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f208.google.com ([209.85.219.208]:54630 "EHLO
	mail-ew0-f208.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029AbZJWVnF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 17:43:05 -0400
Received: by ewy4 with SMTP id 4so2050529ewy.37
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2009 14:43:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20091022135557.GA5162@lenovo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Cyrill Gorcunov - Thu, Oct 22, 2009 at 05:55:57PM +0400]
...
| 
| 2) All handlers set *len to some size explicitly so we may
|    introduce set_sockaddr_size() helper like
| 
| #define set_sockaddr_size(ptr, size)		\
| 	do {					\
| 		build_sockaddr_check(size);	\
| 		*ptr = size;			\
| 	} while (0)
| 
| Or you meant something completely different?
| 
| 	-- Cyrill

Or say it could be something like that

#define __sockaddr(type, src)	\
	({ build_sockaddr_check(sizeof(type)); (type *) src; })

and say in function af_inet.c:inet_getname instead of

	struct sockaddr_in *sin	= (struct sockaddr_in *)uaddr;

we may write like

	struct sockaddr_in *sin	= __sockaddr(struct sockaddr_in, uaddr);

which would check the size.

	-- Cyrill
