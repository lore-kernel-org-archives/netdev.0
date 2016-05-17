From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: don't lose features in netdev_add_tso_features()
Date: Tue, 17 May 2016 14:10:25 -0400 (EDT)
Message-ID: <20160517.141025.306603458593770186.davem@davemloft.net>
References: <1463438015-19529-1-git-send-email-dmichail@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: dmichail@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49177 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751496AbcEQSK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 14:10:27 -0400
In-Reply-To: <1463438015-19529-1-git-send-email-dmichail@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dimitris Michailidis <dmichail@google.com>
Date: Mon, 16 May 2016 15:33:35 -0700

> The goal of netdev_add_tso_features() is to enable all TSO features but
> it unintentionally loses NETIF_F_ALL_FOR_ALL features. This is because
> the netdev_increment_features() it calls clears any NETIF_F_ALL_FOR_ALL
> bits that aren't included in the incremental features and none of them
> are included in NETIF_F_ALL_TSO. The behavior can be seen by enabling
> tx-nocache-copy on the slaves and noticing the feature remains off at
> the master.
> 
> Fix this by including NETIF_F_ALL_FOR_ALL in the incremental features.
> 
> Signed-off-by: Dave Platt <dplatt@google.com>
> Signed-off-by: Dimitris Michailidis <dmichail@google.com>

This doesn't look right to me at all.

The second argument to netdev_increment_features, 'one', clearly
states that all it is supposed to do is handle a new device being
added which has the features mentioned in 'one'.  It makes no sense to
arbitrarily add ALL_FOR_ALL in there, and if it is legitimate, why
doesn't every other call site of netdev_increment_features have this
same problem?

If netdev_increment_features is doing something different either it's
documentation is wrong or it's implementation is losing ALL_FOR_ALL
bits erroneously.
