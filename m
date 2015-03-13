From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3 net-next] rhashtable: Use spin_lock_bh_nested()
 consistently
Date: Fri, 13 Mar 2015 12:54:11 -0400 (EDT)
Message-ID: <20150313.125411.1315810617883806607.davem@davemloft.net>
References: <cover.1426257747.git.tgraf@suug.ch>
	<cover.1426257747.git.tgraf@suug.ch>
	<ad7f4c80fc041ae4aae4e2ed5294ba1f218e6afb.1426257747.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	daniel@iogearbox.net
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51424 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756914AbbCMQyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 12:54:13 -0400
In-Reply-To: <ad7f4c80fc041ae4aae4e2ed5294ba1f218e6afb.1426257747.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Fri, 13 Mar 2015 15:45:20 +0100

> No change in behaviour as the outer lock already disables softirq
> but it prevents bugs down the line as this lock logically requires
> the BH variant.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

I would prefer you don't do this.

x_bh() may be relatively cheap, but it is not zero cost.

If there is an invariant that when we are called here BH
is disabled, make it explicit.
