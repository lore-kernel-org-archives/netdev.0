From: David Miller <davem@davemloft.net>
Subject: Re: on-link assumption in ipv4 routing cache
Date: Mon, 03 Nov 2008 17:32:07 -0800 (PST)
Message-ID: <20081103.173207.246539261.davem@davemloft.net>
References: <48FD2A34.7020702@hp.com>
	<20081020.221312.211946478.davem@davemloft.net>
	<4900B8C0.5020205@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60047
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751433AbYKDBcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 20:32:32 -0500
In-Reply-To: <4900B8C0.5020205@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Thu, 23 Oct 2008 13:47:44 -0400

> Ok, I've found the code and the explanation, but I think there is
> a small bug here that's been around a very long time.  There is absolutely
> no checking for the interface state.  This means that if the interface
> is brought down, we are still going to attempt to route through it.
> That seems broken, since the interface was administratively brought down.
> 
> I've actually tried to do this with my test app.  I've set it to connect
> over a given interface, brought the interface down, and then issued the
> connect().  The result is that the app hung until tcp_syn_retries SYNs have
> been issued and then returned error.
> 
> I've got no issues against on-link assumption as long as there are some smarts
> behind it.  The least we could do is use a running interface.

I agree with you that this behavior is at best sub-optimal.

I'm happy to entertain patches the try to make this
area more sane.
