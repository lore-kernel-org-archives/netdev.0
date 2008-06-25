From: David Miller <davem@davemloft.net>
Subject: Re: Sending big Netlink messages to userspace
Date: Wed, 25 Jun 2008 15:51:46 -0700 (PDT)
Message-ID: <20080625.155146.103043993.davem@davemloft.net>
References: <f4845fc0806240938h36d275ect109fd5f5414cba37@mail.gmail.com>
	<4861282C.4000208@trash.net>
	<20080625104401.GJ20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, juliusv@google.com, netdev@vger.kernel.org,
	vbusam@google.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50786
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751118AbYFYWvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 18:51:46 -0400
In-Reply-To: <20080625104401.GJ20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 25 Jun 2008 12:44:01 +0200

> * Julius Volz <juliusv@google.com> 2008-06-24 20:18
> > libnl hides this from the user, but from reading the code it looks
> > like it now has correct a provision for increasing receive buffer size
> > automatically on seeing MSG_TRUNC. However, it doesn't seem to help in
> > my case...
> 
> libnl initializes the buffer size to the size of a page. The value
> can be overwritten by calling nl_set_buffer_size(socket, rx, tx)

And it doesn't need to be any larger than a page.  Actually, the
hard upper bound is 8K.

The kernel will always chop the response up into chunks of that
size or smaller when generating replies to userspace.

Therefore userland need never have a buffer larger than 8K or
sysconf(_SC_PAGESIZE), whichever is smaller.
