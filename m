From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/4] ipv4: fix route deletion for IPs on many subnets
Date: Tue, 22 Mar 2011 01:07:39 -0700 (PDT)
Message-ID: <20110322.010739.13751001.davem@davemloft.net>
References: <201103192213.p2JMDnvB003074@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58199
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755205Ab1CVIHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 04:07:01 -0400
In-Reply-To: <201103192213.p2JMDnvB003074@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Sun, 20 Mar 2011 00:13:49 +0200

> 	Alex Sidorenko reported for problems with local
> routes left after IP addresses are deleted. It happens
> when same IPs are used in more than one subnet for the
> device.
> 
> 	Fix fib_del_ifaddr to restrict the checks for duplicate
> local and broadcast addresses only to the IFAs that use
> our primary IFA or another primary IFA with same address.
> And we expect the prefsrc to be matched when the routes
> are deleted because it is possible they to differ only by
> prefsrc. This patch prevents local and broadcast routes
> to be leaked until their primary IP is deleted finally
> from the box.
> 
> 	As the secondary address promotion needs to delete
> the routes for all secondaries that used the old primary IFA,
> add option to ignore these secondaries from the checks and
> to assume they are already deleted, so that we can safely
> delete the route while these IFAs are still on the device list.
> 
> Reported-by: Alex Sidorenko <alexandre.sidorenko@hp.com>
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied.
