From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v4] netpoll: fix a rtnl lock assertion failure
Date: Thu, 17 Jan 2013 12:00:45 +0800
Message-ID: <1358395245.3855.12.camel@cr0>
References: <1358242446-4273-1-git-send-email-amwang@redhat.com>
	 <1358385885.32167.21.camel@edumazet-glaptop>
	 <20130116.225238.238898828520417471.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, jiri@resnulli.us
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1058 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758393Ab3AQEPm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 23:15:42 -0500
In-Reply-To: <20130116.225238.238898828520417471.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-16 at 22:52 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 16 Jan 2013 17:24:45 -0800
> 
> >>  	if (np->dev_name)
> >> -		ndev = dev_get_by_name(&init_net, np->dev_name);
> >> +		ndev = __dev_get_by_name(&init_net, np->dev_name);
>  ...
> > Please revert this part.
> 
> You mean just revert that hunk above that made it use the
> non-refcounting version of dev_get_by_name()?

But there is no reason to take both rtnl lock and RCU read lock,
although that is fine.

I think just adding dev_hold() is enough.
