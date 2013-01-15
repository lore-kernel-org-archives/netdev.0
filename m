From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v3] netpoll: fix a rtnl lock assertion failure
Date: Tue, 15 Jan 2013 10:23:45 +0800
Message-ID: <1358216625.4264.4.camel@cr0>
References: <1358160234-24996-1-git-send-email-amwang@redhat.com>
	 <1358183252.8744.3094.camel@edumazet-glaptop>
	 <1358183396.8744.3100.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10683 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756847Ab3AOCX6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2013 21:23:58 -0500
In-Reply-To: <1358183396.8744.3100.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-01-14 at 09:09 -0800, Eric Dumazet wrote:
> On Mon, 2013-01-14 at 09:07 -0800, Eric Dumazet wrote:
> 
> > Strange, why dont we call netdev_master_upper_dev_get() instead ?
> > 
> > 
> 
> What I meant is : the result of this check might be of little use, if we
> don't hold any lock preventing another thread to change things behind
> us.
> 
> 

Even if so, enslaving this device can still happen after we release the
rtnl lock, unless we take this lock for the whole netpoll_setup().

Am I missing anything?
