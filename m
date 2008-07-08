From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: Printing the driver name as part of the netdev watchdog message
Date: Tue, 08 Jul 2008 14:13:43 -0500
Message-ID: <4873BC67.8010205@opengridcomputing.com>
References: <20080706180842.36cc0b1c@extreme>	<20080706.182243.65603166.davem@davemloft.net>	<adafxqlxqi5.fsf@cisco.com>	<20080707.155723.48071035.davem@davemloft.net> <adazlotwalk.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	arjan@infradead.org, netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:41358 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751620AbYGHTNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 15:13:44 -0400
In-Reply-To: <adazlotwalk.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roland Dreier wrote:
>  > I doubt it uses the RTNL semaphore elsewhere to protect
>  > against this path, which is the only protection these
>  > calls currently have.
>
> As far as I can tell from reading the code, the only places in cxgb3
> that use t3_read_flash() are in the netdevice's open and ioctl methods,
> and the ethtool get_drvinfo method.  So as far as I can tell the current
> code is fine as long as rtnl is held across get_drvinfo.
>
>  > Please don't bring up scarecrows, this looks like simply
>  > a bug which already exists.
>
> I don't even know how to take this.  "Please don't review our changes"??
> "Please don't report bugs"??
>
>   

So what is the conclusion here?  If the rtnl doesn't need to be held 
around calls to ethtool ops, then cxgb3 is broken.  In addition, the 
iw_cxgb3 driver is  currently broken too because a recent commit 
(f4e91eb4a81559da87a3843758a641b5cc590b65) accidentally removed 
acquiring of the rtnl before calling an ethtool op in cxgb3.  I want to 
resolve this.

So should I put the rtnl acquisitions back in iw_cxgb3?  Or fix cxgb3 to 
not assume rtnl is held?


Steve.
