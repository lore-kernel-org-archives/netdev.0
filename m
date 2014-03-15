From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 16/16] sfc: Don't receive packets when the
 napi budget == 0
Date: Sat, 15 Mar 2014 12:29:12 -0400 (EDT)
Message-ID: <20140315.122912.1621610280186900725.davem@davemloft.net>
References: <871ty41dps.fsf_-_@xmission.com>
	<87lhwcw9j9.fsf_-_@xmission.com>
	<1394897014.15764.26.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47745 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754478AbaCOQ2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Mar 2014 12:28:21 -0400
In-Reply-To: <1394897014.15764.26.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sat, 15 Mar 2014 15:23:34 +0000

> On Fri, 2014-03-14 at 18:11 -0700, Eric W. Biederman wrote:
>> Processing any incoming packets with a with a napi budget of 0
>> is incorrect driver behavior.
>> 
>> This matters as netpoll will shortly call drivers with a budget of 0
>> to avoid receive packet processing happening in hard irq context.
> 
> But this also prevents handling TX completions, at which point you may
> as well change efx_netpoll() to a no-op.  And then, does it make sense
> to implement ndo_poll_controller at all?
> 
> Note that sfc does have a module parameter to enable separate RX and TX
> completions so they could be polled separately, but it is disabled by
> default.

TX completions should run unconditionally, irregardless of the given
budget.

This is how I have coded all of my drivers, and I how I tell others
to do so.
