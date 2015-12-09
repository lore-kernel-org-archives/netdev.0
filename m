From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] net: Add fib rules at vrf device create
Date: Wed, 09 Dec 2015 15:13:09 -0500 (EST)
Message-ID: <20151209.151309.1866782058292162458.davem@davemloft.net>
References: <1449683012-14145-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com,
	roopa@cumulusnetworks.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38894 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbbLIUNL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 15:13:11 -0500
In-Reply-To: <1449683012-14145-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed,  9 Dec 2015 09:43:32 -0800

> VRFs require ip rules for route lookups to work properly. Currently
> creating a VRF means instantiating a device and then adding the 4 ip
> and ip6 rules:
> 
>     ip link add vrf-${VRF} type vrf table ${TBID}
>     ip link set vrf-${VRF} up
>     ip ru add oif vrf-${VRF} table ${TBID}
>     ip ru add iif vrf-${VRF} table ${TBID}
>     ip -6 ru add oif vrf-${VRF} table $TBID
>     ip -6 ru add iif vrf-${VRF} table $TBID
> 
> Similarly, cleanup requires deleting the link and removing the FIB rules.
> Since the table is required when the vrf device is created the rules can
> be inserted and deleted automatically lightening the overhead and improving
> the user experience (only the ip link commands are needed).
> 
> The VRF driver will only automatically add and remove FIB rules if
> directed by the user per a new IFLA attribute. This new attribute,
> suggested by Roopa, helps maintain backward compatibility with existing
> users that already manage the fib rules directly.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

David, please stop.

Just accept that you failed to design this from the beginning properly
and we're stuck with people having to run multiple commands.

There is zero value to the new attributes.

No matter what you do, users have to use the full sequence of commands
above in order for things to work with all kernels, _FULL STOP_.

The new attributes make things more complex, because ever _VALID_ tool
much accomodate the existing situation and be able to perform all of
the commands above if they are executed on an older kernel.

So the new attributes make things worse, not better.

I will ignore all further attempts to find schemes automate the rule
and route additions, because it is simply the wrong way forward.

Thanks.
