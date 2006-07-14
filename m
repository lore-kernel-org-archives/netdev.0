From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]NET: Add ECN support for TSO
Date: Thu, 13 Jul 2006 22:03:30 -0700 (PDT)
Message-ID: <20060713.220330.118526029.davem@davemloft.net>
References: <1551EAE59135BE47B544934E30FC4FC093F9C3@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ravinandan.arakali@neterion.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, steve.arden@neterion.com,
	Dan.Reader@neterion.com, leonid.grossman@neterion.com,
	ananda.raju@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:21729
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964789AbWGNFDa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 01:03:30 -0400
To: mchan@broadcom.com
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC093F9C3@NT-IRVA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 13 Jul 2006 12:35:37 -0700

> When RFC3540 is implemented, the stack will randomly use ECT(0) or
> ECT(1) on the TSO super segments.  On each of these super segments,
> the hardware will replicate the ECT code point.  This will keep
> everything stateless.  The stack only needs to know the TSO factor
> (number of divided segements) for each TSO super segement to keep
> track of the NS.

Correct, and this is all transparent to the device as long
as it replicates the ECT bit in every sub-frame.

The only real issues are on receive for LRO where the parity
of NS needs to be maintained.
