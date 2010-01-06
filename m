From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Subject: RE: [PATCH NEXT 0/2] qlcnic: Add Qlogic 1/10Gb Ethernet driver for
 CNA devices
Date: Tue, 5 Jan 2010 20:27:24 -0800
Message-ID: <7608421F3572AB4292BB2532AE89D5658B0B6E5012@AVEXMB1.qlogic.org>
References: <7608421F3572AB4292BB2532AE89D5658B0BAE9471@AVEXMB1.qlogic.org>
	<20100105.163343.14826539.davem@davemloft.net>
	<7608421F3572AB4292BB2532AE89D5658B0BAE949E@AVEXMB1.qlogic.org>,<20100105.195156.39644124.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "shemminger@vyatta.com" <shemminger@vyatta.com>,
	Amit Salecha <amit.salecha@qlogic.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:17683 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754247Ab0AFE3I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 23:29:08 -0500
In-Reply-To: <20100105.195156.39644124.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Ok, but you do realize that because GRO maintains enough state
> we can reconstitute packets across forwarding and bridging
> thus decreasing the per-packet costs in those situations as
> well right?
> 
> That's why hardware vendors should strive to align their hw
> LRO implementations with what GRO does, since it is truly
> generic and allows to optimize all cases not just local
> TCP streams.

Yes, GRO has better coverage but HW LRO allows better interrupt
mitigation since fewer buffers are cycled. While the size of
LRO buffer is debatable in terms of memory allocation (recall
discussion on subject "netxen: fix lro buffer allocation"),
it can cause fewer skb allocations.

May be some of this can be achieved with GRO + rx interrupt
coalesce thresholds, etc.

For now, we need to have option of HW LRO that can be turned
off based on use case (NAT etc) via ethtool or whatever.

Thanks,
Dhananjay
