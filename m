From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gro: relax ID check in inet_gro_receive()
Date: Thu, 21 Mar 2013 11:46:16 -0400 (EDT)
Message-ID: <20130321.114616.279859400813363663.davem@davemloft.net>
References: <1363841553.3333.47.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dmitry@broadcom.com, eilong@broadcom.com,
	pshelar@nicira.com, hkchu@google.com, maze@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43458 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932093Ab3CUPqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 11:46:18 -0400
In-Reply-To: <1363841553.3333.47.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 20 Mar 2013 21:52:33 -0700

> GRE TSO support doesn't increment the ID in the inner IP header.

Is this a fundamental limitation of doing TSO over GRO or
were the Broadcom folks just being lazy with their firmware
implementation?

I really don't want to apply this patch, because ipv4 frames
even with DF set should have an incrementing ID field, in
order to accomodate various header compression schemes.

We go out of our way to do this for normal unencapsulated TCP stream
packets, rather than set the ID field to zero (which we did for some
time until the compression issue was pointed out to us).
