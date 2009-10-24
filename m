From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net,socket: introduce build_sockaddr_check helper to
 catch overflow at build time
Date: Sat, 24 Oct 2009 06:12:09 -0700 (PDT)
Message-ID: <20091024.061209.39469983.davem@davemloft.net>
References: <20091022.044914.36401063.davem@davemloft.net>
	<20091022135557.GA5162@lenovo>
	<20091023214306.GA30616@lenovo>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gorcunov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58960
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753325AbZJXNLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2009 09:11:46 -0400
In-Reply-To: <20091023214306.GA30616@lenovo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cyrill Gorcunov <gorcunov@gmail.com>
Date: Sat, 24 Oct 2009 01:43:06 +0400

> Or say it could be something like that
> 
> #define __sockaddr(type, src)	\
> 	({ build_sockaddr_check(sizeof(type)); (type *) src; })
> 
> and say in function af_inet.c:inet_getname instead of
> 
> 	struct sockaddr_in *sin	= (struct sockaddr_in *)uaddr;
> 
> we may write like
> 
> 	struct sockaddr_in *sin	= __sockaddr(struct sockaddr_in, uaddr);
> 
> which would check the size.

Or even a "DECLARE_SOCKADDR(type, src, dest)" which encapsulates the
entire declaration statement.
