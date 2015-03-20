From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] bonding: ban stacked bonding support
Date: Fri, 20 Mar 2015 16:38:45 -0400 (EDT)
Message-ID: <20150320.163845.164991966900600650.davem@davemloft.net>
References: <22754.1424474040@famine>
	<20150320174308.GA2005@p183.telecom.by>
	<20150320174638.GA2053@p183.telecom.by>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vfalico@gmail.com, andy@greyhouse.net, netdev@vger.kernel.org,
	jay.vosburgh@canonical.com
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38344 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977AbbCTUir (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 16:38:47 -0400
In-Reply-To: <20150320174638.GA2053@p183.telecom.by>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Fri, 20 Mar 2015 20:46:38 +0300

> If you add bonding master as a slave, and then release it,
> it will no longer be an IFF_BONDING creating problems like described at
> https://bugzilla.kernel.org/show_bug.cgi?id=89541
> 
> 	echo +bond1 >/sys/class/net/bonding_masters
> 	echo 1 >/sys/class/net/bond1/bonding/mode
> 	echo +bond2 >/sys/class/net/bonding_masters
> 	echo +bond2 >/sys/class/net/bond1/bonding/slaves
> 	echo -bond2 >/sys/class/net/bond1/bonding/slaves
> 	echo -bond2 >/sys/class/net/bonding_masters
> 
> 	cat /proc/net/bonding/bond2	# should not exist
> 		[oops]
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

I feel like this has been brought up before and it was stated that
some people are actually using things like this.

I could be mistaken.
