From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 RFC] 8139cp: Fix GSO MSS handling
Date: Sat, 26 Sep 2015 22:38:55 -0700 (PDT)
Message-ID: <20150926.223855.179450156337919037.davem@davemloft.net>
References: <20150923232931.GA8365@electric-eye.fr.zoreil.com>
	<1443085112.74600.53.camel@infradead.org>
	<1443091102.74600.70.camel@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41033 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189AbbI0Fi5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Sep 2015 01:38:57 -0400
In-Reply-To: <1443091102.74600.70.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Thu, 24 Sep 2015 11:38:22 +0100

> When fixing the TSO support I noticed we just mask ->gso_size with the
> MSSMask value and don't care about the consequences.
> 
> Provide a .ndo_features_check() method which drops the NETIF_F_TSO
> feature for any skb which would exceed the maximum, and thus forces it
> to be segmented by software.
> 
> Then we can stop the masking in cp_start_xmit(), and just WARN if the
> maximum is exceeded, which should now never happen.
> 
> Finally, Francois Romieu noticed that we didn't even have the right
> value for MSSMask anyway; it should be 0x7ff (11 bits) not 0xfff.
> 
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

I'm going to apply this to net-next, thanks David.
