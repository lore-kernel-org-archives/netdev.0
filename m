From: Dan Williams <dcbw@redhat.com>
Subject: Re: [patch 1/3] softmac: return -EAGAIN from getscan while scanning
Date: Thu, 13 Apr 2006 08:12:55 -0400
Message-ID: <1144930375.2372.10.camel@localhost.localdomain>
References: <20060411085805.949313000@sipsolutions.net>
	 <20060411085841.252064000@sipsolutions.net>
	 <20060413020010.2ab16d7b.zaitcev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org,
	linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:55179 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S964831AbWDMMOm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2006 08:14:42 -0400
To: Pete Zaitcev <zaitcev@redhat.com>
In-Reply-To: <20060413020010.2ab16d7b.zaitcev@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-04-13 at 02:00 -0700, Pete Zaitcev wrote:
> On Tue, 11 Apr 2006 10:58:06 +0200, johannes@sipsolutions.net wrote:
> 
> > Below patch was developed after discussion with Daniel Drake who
> > mentioned to me that wireless tools expect an EAGAIN return from getscan
> > so that they can wait for the scan to finish before printing out the
> > results.
> 
> This sounds completely wrong. Do you guys remember the Subject: string
> of this discussion by any chance?

Maybe it's wrong now, but it's how the CLI tools have operated for quite
a while AFAIK.

There are two options for tools: (a) request scan and block on GIWSCAN
until it doesn't return EAGAIN, or (b) request a scan, enter a loop,
wait for the GIWSCAN netlink message to come back.  The point here is
that if you have to write a tool with 100 lines of netlink message
processing code _just_ to get the "scan done!" message, that's a bitch.
More complicated programs can obviously do this, but simple tools don't
want or need to.

airo, atmel, and orinoco all do this.  ipw does not, and prism54 does
not because it does background scanning.  I believe that the patch for
softmac/bcm43xx EAGAIN is correct.

Dan


