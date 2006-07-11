From: Ben Greear <greearb@candelatech.com>
Subject: Re: Question on device events and unregister_netdev.
Date: Tue, 11 Jul 2006 16:48:46 -0700
Message-ID: <44B438DE.3020503@candelatech.com>
References: <44B433DD.8070100@candelatech.com> <20060711.164331.122338629.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:7566 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S932256AbWGKXst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2006 19:48:49 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060711.164331.122338629.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Ben Greear <greearb@candelatech.com>
> Date: Tue, 11 Jul 2006 16:27:25 -0700
> 
> 
>>So, the question is: Should I be calling unregister_netdev from the
>>notifier callback?
> 
> 
> Not really, as you saw it can be deadlock prone.
> 
> One idea is to run the unregister asynchronously via a workqueue.
> That should be able to get you out of the deadlock.

After more poking, I notice that 802.1q uses unregister_netdevice,
which does not grab rtnl.  It seems that the notifiers are always called
with rtnl asserted.  That would be a recursive call to unregister_netdevice,
however...any reason that won't work?

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

