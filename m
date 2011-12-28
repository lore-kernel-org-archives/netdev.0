From: David Miller <davem@davemloft.net>
Subject: Re: The mystery of optimistic ipv6 DAD handling
Date: Wed, 28 Dec 2011 14:38:12 -0500 (EST)
Message-ID: <20111228.143812.206477268839022030.davem@davemloft.net>
References: <20111228151928.GA12025@neilslaptop.think-freely.org>
	<20111228.133933.866545698956085305.davem@davemloft.net>
	<20111228192150.GA16499@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57199 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754325Ab1L1TjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2011 14:39:17 -0500
In-Reply-To: <20111228192150.GA16499@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 28 Dec 2011 14:21:50 -0500

> Clearly I misread the RFC the first time through and the test as it existed is
> incorrect.  I'm wondering though if what we need is a way to lookup if we've
> received a RA on the interface, and check to see if it has a source link layer
> option attached to it.

Yes, we could implement this with a new neigh lookup routine, that allows
keying on device pointer and flags.

So in this case we'd pass the device and NTF_ROUTER.  If the lookup returns
non-NULL then we've seen an RA with SLLAO specified.
