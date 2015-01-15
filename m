From: Jeff Layton <jeff.layton@primarydata.com>
Subject: Re: [ 2375.793397] WARNING: CPU: 0 PID: 1149 at
 net/netlink/genetlink.c:1037 genl_unbind+0xc0/0xd0()
Date: Wed, 14 Jan 2015 21:20:39 -0500
Message-ID: <20150114212039.68c9a5a6@synchrony.poochiereds.net>
References: <20150114161334.28acf5fc@tlielax.poochiereds.net>
	<1421275700.1950.34.camel@sipsolutions.net>
	<1421277946.1950.38.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Layton <jeff.layton@primarydata.com>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:56708 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751187AbbAOCUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 21:20:42 -0500
Received: by mail-qg0-f51.google.com with SMTP id i50so9898468qgf.10
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 18:20:42 -0800 (PST)
In-Reply-To: <1421277946.1950.38.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Jan 2015 00:25:46 +0100
Johannes Berg <johannes@sipsolutions.net> wrote:

> On Wed, 2015-01-14 at 23:48 +0100, Johannes Berg wrote:
> 
> > > [ 2375.793396] ------------[ cut here ]------------
> > > [ 2375.793397] WARNING: CPU: 0 PID: 1149 at net/netlink/genetlink.c:1037 genl_unbind+0xc0/0xd0()
> > 
> > This warning is supposed to happen only when you somehow manage to
> > unsubscribe from a generic netlink group that doesn't actually exist, or
> > so.
> 
> Ok - after long deliberation I found a way to trigger it. It requires
> that you leave a multicast group (likely by destroying a socket) at the
> same time as the kernel unregisters the generic netlink group. I have no
> idea what generic netlink group you might be using here, but I could
> reproduce it with a strategically placed delay in the netlink code and
> the nl80211 genl group by opening a socket, closing the socket, and
> removing the cfg80211 module (to unregister the nl80211 genl group)
> while the socket was still being closed.
> 
> I'll think about a fix tomorrow - it doesn't seem trivial due to
> possible locking concerns.
> 
> On the bright side, I cannot see a way to reproduce this without
> removing the genl family at the same time - which is good because it
> means that I've just again audited the case I was worried about (the
> bind/unbind not being symmetric) - it is asymmetric but only in the case
> of genl family removal which seems reasonable (but I should document
> it.)
> 
> johannes
> 

Cool.

FWIW, it popped around a dozen times or so?

Unfortunately, I didn't save the logs from the run. I'll try to
reproduce it again tomorrow (and save the logs this time), but I don't
see it every time.

-- 
Jeff Layton <jlayton@primarydata.com>
