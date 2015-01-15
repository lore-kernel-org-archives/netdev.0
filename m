From: Jeff Layton <jeff.layton@primarydata.com>
Subject: Re: [ 2375.793397] WARNING: CPU: 0 PID: 1149 at
 net/netlink/genetlink.c:1037 genl_unbind+0xc0/0xd0()
Date: Thu, 15 Jan 2015 07:49:56 -0500
Message-ID: <20150115074956.4e5617cd@tlielax.poochiereds.net>
References: <20150114161334.28acf5fc@tlielax.poochiereds.net>
	<1421275700.1950.34.camel@sipsolutions.net>
	<1421277946.1950.38.camel@sipsolutions.net>
	<20150114212039.68c9a5a6@synchrony.poochiereds.net>
	<1421311071.1962.2.camel@sipsolutions.net>
	<20150115071426.563573e7@tlielax.poochiereds.net>
	<1421324985.1962.5.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Layton <jeff.layton@primarydata.com>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:40067 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751947AbbAOMt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 07:49:59 -0500
Received: by mail-qc0-f175.google.com with SMTP id p6so11891512qcv.6
        for <netdev@vger.kernel.org>; Thu, 15 Jan 2015 04:49:58 -0800 (PST)
In-Reply-To: <1421324985.1962.5.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Jan 2015 13:29:45 +0100
Johannes Berg <johannes@sipsolutions.net> wrote:

> On Thu, 2015-01-15 at 07:14 -0500, Jeff Layton wrote:
> 
> > I was able to reproduce it again this morning. This time it generated
> > 28 warnings (all with similar stack traces to the one I posted
> > yesterday).
> 
> Thanks. I just took a look at this, and it seems that sadly it doesn't
> include netlink messages in the log? At least I didn't find them - so I
> don't really know what happened. What I was thinking happened would
> (mostly) play out over netlink messages.
> 

(re-cc'ing netdev -- I sent Johannes the log in a private email as
 it was 12M compressed)

It may have. I just recently started playing with trinity, so I don't
know much about what it does. I do see these sorts of messages in the
logs that imply that it's opening netlink sockets:

[main] fd[661] = domain:16 (PF_NETLINK) type:0x2 protocol:10
[main] fd[675] = domain:16 (PF_NETLINK) type:0x2 protocol:0

...and then it does random I/Os on those fds.

> > I haven't tested your patchset out yet, but I can try to do that
> > later.
> 
> You won't be able to reproduce the warning with it since I removed it
> there. I'm reasonably certain though that you triggered one of the two
> cases I found, more likely the former that doesn't involve removing
> genetlink families (don't see how you could have done that with trinity
> unless it randomly loads and unloads modules?)
> 

Ok, sounds good.

FWIW, it tries to call delete_module, but I was running this as an
unprivileged user so I don't think that can succeed.

-- 
Jeff Layton <jlayton@primarydata.com>
