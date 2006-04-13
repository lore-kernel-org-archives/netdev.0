From: Pete Zaitcev <zaitcev@redhat.com>
Subject: Re: [patch 1/3] softmac: return -EAGAIN from getscan while scanning
Date: Thu, 13 Apr 2006 15:21:48 -0700
Message-ID: <20060413152148.eba6a4de.zaitcev@redhat.com>
References: <20060411085805.949313000@sipsolutions.net>
	<20060411085841.252064000@sipsolutions.net>
	<20060413020010.2ab16d7b.zaitcev@redhat.com>
	<1144930375.2372.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org,
	linville@tuxdriver.com, zaitcev@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41953 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S932464AbWDMWWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2006 18:22:15 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1144930375.2372.10.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 13 Apr 2006 08:12:55 -0400, Dan Williams <dcbw@redhat.com> wrote:

> > This sounds completely wrong. Do you guys remember the Subject: string
> > of this discussion by any chance?

> There are two options for tools: (a) request scan and block on GIWSCAN
> until it doesn't return EAGAIN, or (b) request a scan, enter a loop,
> wait for the GIWSCAN netlink message to come back.  The point here is
> that if you have to write a tool with 100 lines of netlink message
> processing code _just_ to get the "scan done!" message, that's a bitch.
> More complicated programs can obviously do this, but simple tools don't
> want or need to.

Do you realize that "block" means "enterering the kernel and calling
schedule()", which is exactly what is NOT happening in the patch?
I would not mind if the tools "blocked in GIWSCAN", only until
it returns success and not EGAIN.

With EAGAIN returned, you have to a) block elsewhere and not in
GIWSCAN (perhaps in sleep(2) or select(2)), or b) not block at all
and loop.

> I believe that the patch for softmac/bcm43xx EAGAIN is correct.

It is correct, no doubt. The discussion is about wether it is
desirable.

-- Pete
