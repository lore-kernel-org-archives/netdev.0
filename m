From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/11] DMA sync errors
Date: Wed, 20 Jan 2010 14:46:39 -0800 (PST)
Message-ID: <20100120.144639.31770545.davem@davemloft.net>
References: <20100120204459.820265084@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60217
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753988Ab0ATWq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 17:46:29 -0500
In-Reply-To: <20100120204459.820265084@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 20 Jan 2010 12:44:59 -0800

> According to the DMA-API.txt
>   Synchronise a single contiguous or scatter/gather mapping.  All the
>   parameters must be the same as those passed into the single mapping
>   API.

I think this is unreasonable.

And it's going to kill performance for reception of small packets.

We might as well not do RX copybreak in any of these drivers any more
if we have to DMA sync the whole thing.

I think better to look at the various implementations of DMA APIs,
I bet they all handle this case just fine.  And those that don't
are easily fixed.  Then the documentation can be updated to match
and we can forget these crazy patches.
