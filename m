From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] bnx2x: Handle Rx and Tx together in NAPI
Date: Mon, 16 Nov 2009 02:20:12 -0800 (PST)
Message-ID: <20091116.022012.81633492.davem@davemloft.net>
References: <1258365669.8392.3.camel@lb-tlvb-vladz.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59098
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751893AbZKPKT4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 05:19:56 -0500
In-Reply-To: <1258365669.8392.3.camel@lb-tlvb-vladz.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Mon, 16 Nov 2009 12:01:09 +0200

>   - Limit Tx work done in one iteration by the same number of packets as
> Rx in order to ensure both fair work load balancing relatively to other
> devices scheduled for NAPI on the local CPU and sane Tx/Rx skb resource
> management from single QP perspective.

You should not do this.

RX is several orders of magnitude more work than TX is.  TX therefore
should not be charged against the NAPI polling quota.

Don't try to be different from other drivers unless you have detailed
performance numbers from various situations (local TCP flows _and_
routing) to justify it. :-)

All NAPI drivers ignore TX work when considering NAPI polling quotas
and you should too :-)
