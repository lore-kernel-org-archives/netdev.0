From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 5/7] via-velocity: Re-enable transmit scatter-gather
 support
Date: Thu, 26 Nov 2009 13:09:34 -0800 (PST)
Message-ID: <20091126.130934.155634662.davem@davemloft.net>
References: <20091125092213.423d0dd7@marrow.netinsight.se>
	<20091125.153735.28806618.davem@davemloft.net>
	<20091126083641.4f961ce5@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davej@redhat.com, shemminger@vyatta.com,
	romieu@fr.zoreil.com
To: simon.kagstrom@netinsight.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35224
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750946AbZKZVJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2009 16:09:16 -0500
In-Reply-To: <20091126083641.4f961ce5@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Date: Thu, 26 Nov 2009 08:36:41 +0100

> and after having crunched this in my head for a while, I couldn't
> convince myself that nr_frags would always come out as less than 7 from
> here. I don't claim to have done a thorough examination though.

__skb_linearize() does pskb_pull_tail() with length skb->data_len

skb->data_len represents the length of the data represented by non-linear
buffers in the SKB.

Therfore ending up with ->nr_frags != 0 or ->frag_list != NULL after this
operation would be a bug, and not something we should assert about in
driver code.
