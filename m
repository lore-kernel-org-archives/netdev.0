From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rds: fix local ping DoS
Date: Thu, 14 Nov 2013 02:03:55 -0500 (EST)
Message-ID: <20131114.020355.1973894145326845195.davem@davemloft.net>
References: <1384391743-9342-1-git-send-email-johunt@akamai.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, venkat.x.venkatsubra@oracle.com,
	linux-kernel@vger.kernel.org, jjolly@suse.com, fenlason@redhat.com,
	honli@redhat.com
To: johunt@akamai.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48003 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104Ab3KNHD5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 02:03:57 -0500
In-Reply-To: <1384391743-9342-1-git-send-email-johunt@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josh Hunt <johunt@akamai.com>
Date: Wed, 13 Nov 2013 17:15:43 -0800

> The rds_ib_xmit function in net/rds/ib_send.c in the Reliable Datagram Sockets
> (RDS) protocol implementation allows local users to cause a denial of service
> (BUG_ON and kernel panic) by establishing an RDS connection with the source
> IP address equal to the IPoIB interface's own IP address, as demonstrated by
> rds-ping.
> 
> A local unprivileged user could use this flaw to crash the system.
> 
> CVE-2012-2372
> 
> Reported-by: Honggang Li <honli@redhat.com>
> Signed-off-by: Josh Hunt <johunt@akamai.com>

I'm sorry I can't apply this.  This commit message needs to be much
less terse and explain things more.

First of all, why is the "off % RDS_FRAG_SIZE" important?

And, even more importantly, why is is OK to avoid this assertion just
because we're going over loopback?

Furthermore, why doesn't net/rds/iw_send.c:rds_iw_xmit() have the same
exact problem?  It makes the same exact assertion check.

I know this RDS code is a steaming pile of poo, but that doesn't mean
we just randomly adjust assertions to make crashes go away without
sufficient understanding of exactly what's going on.

Thanks.
