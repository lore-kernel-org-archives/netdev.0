From: Thomas Graf <tgraf@suug.ch>
Subject: Re: New address announcements in RTMGRP_IPV4_IFADDR netlink group
Date: Mon, 6 Jun 2005 21:54:22 +0200
Message-ID: <20050606195422.GJ15391@postel.suug.ch>
References: <aa027950f2fc7f2ad640cac4a11fbe93@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Teemu Koponen <tkoponen@iki.fi>
Content-Disposition: inline
In-Reply-To: <aa027950f2fc7f2ad640cac4a11fbe93@iki.fi>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Teemu Koponen <aa027950f2fc7f2ad640cac4a11fbe93@iki.fi> 2005-06-06 11:59
> 0) A userspace daemon process is running and listening to the broadcast 
> group.
> 
> 1) Address is inserted to an interface (ip addr add ... at shell).
> 
> 2) The daemon receives a NEWADDR message, just as is should, but the 
> daemon is unable to bind to the address *immediately* (actually in the 
> function that processes the netlink message). The result is "cannot 
> assign an address" from the bind call. However, if I do insert a single 
> nanosleep, even with an arbitrary low sleep value, before the bind 
> call, the bind then succeeds.
> 
> So, what is the semantics of NEWADDR? Should the address be bindable 
> right after receiving the message?

The bind() call doesn't fail because of the address being non-existant,
it fails because the route has not been created for it. The netlink
message is generated before we notify the other subsystems about the
addition of a new address so you try to bind to an adress for which
no route has been generated yet. The best solution is probably to wait
for the route addition notification message being received and then
bind to that address.
