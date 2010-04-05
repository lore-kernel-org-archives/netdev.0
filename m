From: David Miller <davem@davemloft.net>
Subject: Re: Undefined behaviour of connect(fd, NULL, 0);
Date: Mon, 05 Apr 2010 12:25:54 -0700 (PDT)
Message-ID: <20100405.122554.232915662.davem@davemloft.net>
References: <x2j412e6f7f1003312116rd3b3ba96t31267545efe7660f@mail.gmail.com>
	<20100401.002319.236233308.davem@davemloft.net>
	<w2n412e6f7f1004050223j3e15df91tcdf133670c636a85@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: neilb@suse.de, shemminger@vyatta.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35865
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755775Ab0DETZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 15:25:51 -0400
In-Reply-To: <w2n412e6f7f1004050223j3e15df91tcdf133670c636a85@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Mon, 5 Apr 2010 17:23:50 +0800

> I found this from the man page of FreeBSD's connect(2).
> 
>      Generally, stream sockets may successfully connect() only
>      once; datagram sockets may use connect() multiple times to change their
>      association.  Datagram sockets may dissolve the association by connecting
>      to an invalid address, such as a null address.
> 
> And this from the man page of Darwin's connect(2).
> 
>      Datagram sockets may dissolve the association by connecting to an
>      invalid address, such as a null address or an address with the address
>      family set to AF_UNSPEC (the error EAFNOSUPPORT will be harmlessly
>      returned).
> 
> Since null address behavior has been defined by the others. I think
> Linux should be compatible with the others. So the  patch submitted on
> this by me should not been applied. I'll work out another patch later.

Your patch is already applied and pushed out to the world.
Any corrections would need to be made relative to that.

But I think no changes should be made, and it doesn't matter
at all what some manual page says on another system.

It doesn't matter one iota what those paragraphs say, we've had the
existing behavior for FIFTEEN YEARS.  So, like I said last time, any
application coding to this behavior of the zero length sockaddr doing
anything on connect() will NOT WORK ON ANY KERNEL.

So supporting it has absolutely zero value, for us and for app
developers.


