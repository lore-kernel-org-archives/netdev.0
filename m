From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Subject: RE: [PATCH NEXT 0/2] qlcnic: Add Qlogic 1/10Gb Ethernet driver for
 CNA devices
Date: Tue, 5 Jan 2010 11:02:00 -0800
Message-ID: <7608421F3572AB4292BB2532AE89D5658B0BAE9411@AVEXMB1.qlogic.org>
References: <1262697876-26206-1-git-send-email-amit.salecha@qlogic.com>
	<20100105091548.57caf0a4@nehalam>
	<7608421F3572AB4292BB2532AE89D5658B0BAE9402@AVEXMB1.qlogic.org>
 <20100105104556.14927d40@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Amit Salecha <amit.salecha@qlogic.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:47212 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753780Ab0AETDn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 14:03:43 -0500
In-Reply-To: <20100105104556.14927d40@nehalam>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> You should be doing GRO, what about multiple addresses per interface,
> bridging, routing, ...

We do GRO too (that helps when old firmware didn't support LRO).
Since all addresses associated with a net device are tracked
we do take care of IP aliases. Note that LRO packets are not
fed into GRO, although there's nothing that prevents it.

On older machines, GRO tops out CPU to get close to line rate,
LRO doesn't. Also, LRO reduces number of PCIe transactions.

LRO across bridge / routing is topology violation right?
We don't get inet notification for remote IP addresses (correct
me if wrong), so these cases are excluded from LRO.

-Dhananjay
