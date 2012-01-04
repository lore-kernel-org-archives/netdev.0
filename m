From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Check RA for sllao when configuring optimistic
 ipv6 address (v2)
Date: Wed, 04 Jan 2012 15:53:35 -0500 (EST)
Message-ID: <20120104.155335.352434092951444020.davem@davemloft.net>
References: <1325695643-27656-1-git-send-email-nhorman@tuxdriver.com>
	<1325710155-30289-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52725 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756825Ab2ADU4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 15:56:24 -0500
In-Reply-To: <1325710155-30289-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed,  4 Jan 2012 15:49:15 -0500

> Recently Dave noticed that a test we did in ipv6_add_addr to see if we next hop
> route for the interface we're adding an addres to was wrong (see commit
> 7ffbcecbeed91e5874e9a1cfc4c0cbb07dac3069).  for one, it never triggers, and two,
> it was completely wrong to begin with.  This test was meant to cover this
> section of RFC 4429:
> 
> 3.3 Modifications to RFC 2462 Stateless Address Autoconfiguration
> 
>    * (modifies section 5.5) A host MAY choose to configure a new address
>         as an Optimistic Address.  A host that does not know the SLLAO
>         of its router SHOULD NOT configure a new address as Optimistic.
>         A router SHOULD NOT configure an Optimistic Address.
> 
> This patch should bring us into proper compliance with the above clause.  Since
> we only add a SLAAC address after we've received a RA which may or may not
> contain a source link layer address option, we can pass a pointer to that option
> to addrconf_prefix_rcv (which may be null if the option is not present), and
> only set the optimistic flag if the option was found in the RA.
> 
> Change notes:
> (v2) modified the new parameter to addrconf_prefix_rcv to be a bool rather than
> a pointer to make its use more clear as per request from davem.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied, thanks Neil.
