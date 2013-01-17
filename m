From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v4] netpoll: fix a rtnl lock assertion failure
Date: Thu, 17 Jan 2013 12:18:04 +0800
Message-ID: <1358396284.3855.16.camel@cr0>
References: <1358242446-4273-1-git-send-email-amwang@redhat.com>
	 <1358385885.32167.21.camel@edumazet-glaptop> <1358393418.3855.3.camel@cr0>
	 <20130116.225413.1184047803896995845.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, jiri@resnulli.us
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3659 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758539Ab3AQESN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 23:18:13 -0500
In-Reply-To: <20130116.225413.1184047803896995845.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-16 at 22:54 -0500, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Thu, 17 Jan 2013 11:30:18 +0800
> 
> > On Wed, 2013-01-16 at 17:24 -0800, Eric Dumazet wrote:
> >> On Tue, 2013-01-15 at 17:34 +0800, Cong Wang wrote:
> >> >  	if (np->dev_name)
> >> > -		ndev = dev_get_by_name(&init_net, np->dev_name);
> >> > +		ndev = __dev_get_by_name(&init_net, np->dev_name);
> >> 
> >> This change brings interesting bugs.
> > 
> > Hmm, I didn't realize __dev_get_by_name() doesn't hold the device, so
> > just call dev_hold() after this?
> 
> Why not just... call dev_get_by_name()?  It doesn't hurt to over-RCU
> lock.
> 

Just that taking RCU read lock while having rtnl lock is unnecessary, no
other reason.
