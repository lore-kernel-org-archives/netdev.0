From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [ 2375.793397] WARNING: CPU: 0 PID: 1149 at
 net/netlink/genetlink.c:1037 genl_unbind+0xc0/0xd0()
Date: Thu, 15 Jan 2015 14:01:08 +0100
Message-ID: <1421326868.1962.13.camel@sipsolutions.net>
References: <20150114161334.28acf5fc@tlielax.poochiereds.net>
	 <1421275700.1950.34.camel@sipsolutions.net>
	 <1421277946.1950.38.camel@sipsolutions.net>
	 <20150114212039.68c9a5a6@synchrony.poochiereds.net>
	 <1421311071.1962.2.camel@sipsolutions.net>
	 <20150115071426.563573e7@tlielax.poochiereds.net>
	 <1421324985.1962.5.camel@sipsolutions.net>
	 <20150115074956.4e5617cd@tlielax.poochiereds.net>
	 (sfid-20150115_134959_506751_D19674F4)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Layton <jeff.layton@primarydata.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:36218 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754143AbbAONBM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2015 08:01:12 -0500
In-Reply-To: <20150115074956.4e5617cd@tlielax.poochiereds.net> (sfid-20150115_134959_506751_D19674F4)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-15 at 07:49 -0500, Jeff Layton wrote:

> It may have. I just recently started playing with trinity, so I don't
> know much about what it does. I do see these sorts of messages in the
> logs that imply that it's opening netlink sockets:
> 
> [main] fd[661] = domain:16 (PF_NETLINK) type:0x2 protocol:10
> [main] fd[675] = domain:16 (PF_NETLINK) type:0x2 protocol:0
> 
> ...and then it does random I/Os on those fds.

Yes. We're looking for generic netlink, so one of these (protocol 16):

[main] fd[427] = domain:16 (PF_NETLINK) type:0x3 protocol:16
[main] fd[442] = domain:16 (PF_NETLINK) type:0x2 protocol:16
[main] fd[774] = domain:16 (PF_NETLINK) type:0x2 protocol:16

However, I didn't see much happening on these fds, and even if it
wouldn't have recorded the kind of messages.

OTOH, multicast group stuff is done with setsockopt() and/or bind, which
I didn't really find here?

> FWIW, it tries to call delete_module, but I was running this as an
> unprivileged user so I don't think that can succeed.

Ok.

johannes
