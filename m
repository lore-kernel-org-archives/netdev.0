From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] netdev sysfs failure handling
Date: Sat, 06 May 2006 18:06:22 -0700 (PDT)
Message-ID: <20060506.180622.117885702.davem@davemloft.net>
References: <20060421134205.2786a0ee@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:9398
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750789AbWEGBGT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 May 2006 21:06:19 -0400
To: shemminger@osdl.org
In-Reply-To: <20060421134205.2786a0ee@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Fri, 21 Apr 2006 13:42:05 -0700

> In case of sysfs failure, don't let device be brought up.
> It can be cleared by unregister_netdevice so module can be unloaded
> normally.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

I'm not so sure about this, a hot plug event could clear that bit too.

The problem I think is that here we've structured things such that we
can't handle the error properly and pass it back to the
register_netdevice() caller because we do the sysfs registry call in
the rtnl_unlock() todo list execution.

Next, even if you prevent the device from being brought up, people
can still assign IP addresses and do other stuff to the device so
it still sort of behaves as if it is there.

It would therefore be the best if we can do this stuff inside of
register_netdevice(), then handle and propagate any errors correctly.
