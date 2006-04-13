From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [patch 1/3] softmac: return -EAGAIN from getscan while scanning
Date: Thu, 13 Apr 2006 09:13:59 -0700
Message-ID: <20060413161359.GA21074@bougret.hpl.hp.com>
References: <20060411085805.949313000@sipsolutions.net> <20060411085841.252064000@sipsolutions.net> <20060413020010.2ab16d7b.zaitcev@redhat.com> <1144919176.4187.44.camel@localhost> <1144920890.4187.50.camel@localhost> <1144930441.2372.12.camel@localhost.localdomain>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Pete Zaitcev <zaitcev@redhat.com>, netdev@vger.kernel.org,
	softmac-dev@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ccerelbas03.cce.hp.com ([161.114.21.106]:737 "EHLO
	ccerelbas03.cce.hp.com") by vger.kernel.org with ESMTP
	id S1751051AbWDMQON (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 12:14:13 -0400
To: Dan Williams <dcbw@redhat.com>
Content-Disposition: inline
In-Reply-To: <1144930441.2372.12.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 13, 2006 at 08:14:01AM -0400, Dan Williams wrote:
> On Thu, 2006-04-13 at 11:34 +0200, Johannes Berg wrote:
> > On Thu, 2006-04-13 at 11:06 +0200, Johannes Berg wrote:
> > 
> > > > It's very likely that tools do indeed loop when they see EAGAIN, but
> > > > this is a workaround, not the main mode of operation. It seems obvious
> > > > to me that the get method should wait until the scan results are
> > > > available. Perhaps the discussion had a specific scenario where
> > > > EAGAIN would make sense, but I cannot imagine what it might be.
> > > 
> > > Right, they do loop, but they don't have a method to indicate
> > > completion. Thus we'd have to actually wait for the completion in the
> > > kernel. Jean, what is the intended use here?
> > 
> > Hah, never mind, I guess we're just supposed to send SIOCGIWSCAN. Will
> > send a patch in a minute.
> 
> No, you should be doing both really.  If you don't do EAGAIN, then tools
> like iwlist and other simple ones that don't want to spend 100 lines of
> code in netlink message processing just to receive the wireless event
> won't work very well.
> 
> Dan

	Yes, Dan is 100% correct.

	Jean

