From: jamal <hadi@cyberus.ca>
Subject: Re: multicast group memberships purge on interface delete
Date: Wed, 23 Aug 2006 08:32:11 -0400
Message-ID: <1156336331.5035.79.camel@jzny2>
References: <20060809.195627.59155708.yoshfuji@linux-ipv6.org>
	 <44D9D431.10101@tcs.hut.fi>	<44DA558A.1080706@tcs.hut.fi>
	 <20060810.174635.42119608.yoshfuji@linux-ipv6.org>
	 <44DB0870.6000902@tcs.hut.fi> <019901c6bc75$872ee1f0$2303a8c0@mruzicka>
	 <021e01c6c6a4$6e7845f0$2303a8c0@mruzicka>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:31617 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S932441AbWHWMcX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 08:32:23 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1GFru4-000617-RO
	for netdev@vger.kernel.org; Wed, 23 Aug 2006 08:32:16 -0400
To: Michal Ruzicka <michal.ruzicka@comstar.cz>
In-Reply-To: <021e01c6c6a4$6e7845f0$2303a8c0@mruzicka>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-23-08 at 13:08 +0200, Michal Ruzicka wrote:

> My question/suggestion:
> Would it feasible to drop the relevant entries from sockets' multicast 
> membership lists on the interface
> delete? Yes, I do realize it would require to walk through a number of 
> sockets to see if there is any
> multicast entry for the interface in question to delete. But this could be 
> optimized by maintaining a list
> of sockets that have a multicast group joined on the interface (and keep a 
> pointer to this list in the
> device structure). This would ease the job of the function handling leaving 
> multicast groups, made
> its beahaviour more "deterministic" and possible errors reported by it more 
> meaningful/reliable.
> 

You should be able to "fix it" in the kernel by listening to events of
the interface/device disappearing. By "disappearing" i think you meant
the netdevice was totally rmmod-ed? The challenge is to make the app
also aware of you taking away the group from underneath them (thats why
i said "fix it")

These events are also available in user space via netlink. so an alter
your app could listen to them and make the group leaves instead of the
kernel.

cheers,
jamal


