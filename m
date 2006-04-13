From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [patch 1/3] softmac: return -EAGAIN from getscan while scanning
Date: Thu, 13 Apr 2006 16:58:03 -0700
Message-ID: <20060413235803.GA23116@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from tayrelbas01.tay.hp.com ([161.114.80.244]:36225 "EHLO
	tayrelbas01.tay.hp.com") by vger.kernel.org with ESMTP
	id S965055AbWDMX6G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 19:58:06 -0400
To: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org,
	Pete Zaitcev <zaitcev@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pete Zaitcev wrote :
> 
> Do you realize that "block" means "enterering the kernel and calling
> schedule()", which is exactly what is NOT happening in the patch?
> I would not mind if the tools "blocked in GIWSCAN", only until
> it returns success and not EGAIN.

	Do you realise that "block" means holding the netlink
mutex. Which means any networking ioctl and netlink operation is
blocked, which means ifconfig and iproute are blocked.
	The MadWifi driver take up to 15sec to perfom scanning.

> With EAGAIN returned, you have to a) block elsewhere and not in
> GIWSCAN (perhaps in sleep(2) or select(2)), or b) not block at all
> and loop.

	User-space authors are no dummy, they know that looping on
EAGAIN is bad, so most do a sleep (actually most user-space use libiw
which does a sleep).

> It is correct, no doubt. The discussion is about wether it is
> desirable.

	Yes, it is desirable, because we are pragmatic.

	Jean
