From: David Miller <davem@davemloft.net>
Subject: Re: Undefined behaviour of connect(fd, NULL, 0);
Date: Thu, 01 Apr 2010 00:23:19 -0700 (PDT)
Message-ID: <20100401.002319.236233308.davem@davemloft.net>
References: <n2w412e6f7f1003312000o3a69802j120acd3946458517@mail.gmail.com>
	<20100401143805.1f83a161@notabene.brown>
	<x2j412e6f7f1003312116rd3b3ba96t31267545efe7660f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: neilb@suse.de, shemminger@vyatta.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41433
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752514Ab0DAHXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 03:23:18 -0400
In-Reply-To: <x2j412e6f7f1003312116rd3b3ba96t31267545efe7660f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Thu, 1 Apr 2010 12:16:43 +0800

> Someone may use connect() to check if the connection is established
> or not. But there is no spec about the addr and addr_len value when
> connect(2) is used this way. Since there is no limit of addr and
> addr_len, and we supports addr is NULL to check the status of socket
> (Although it is buggy). I think we should treat it like a feature,
> and the problem Neil reported is a bug.

This seems logical, but I believe it is wrong.

We already know for a fact that it is guarenteed to not work
reliably for every single kernel in existence in the world
right now.

Every system.  Ones that have been deployed for 10 years as
well as those built from GIT 10 seconds ago.

So you tell me, if you put this into an application that you
wish to deploy anywhere, are you not being completely stupid?

Therefore, if it's illogical to use this in an application, what value
is there in starting to support it now in the kernel?

I'll tell you, the value is absolutely zero.

Yes we need to add the length check, but the behavior we give to this
case as a result, is completely arbitrary.  And I would in fact argue
for a hard error in these cases.

Simply mark it as invalid to call connect() this way.
