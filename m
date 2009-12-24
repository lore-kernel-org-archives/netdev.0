From: David Miller <davem@davemloft.net>
Subject: gianfar select_queue bogosity (was Re: ixgbe warning)
Date: Wed, 23 Dec 2009 21:11:57 -0800 (PST)
Message-ID: <20091223.211157.68124463.davem@davemloft.net>
References: <86802c440912222100j1c23f3d9xfb734a6e52fa2ec9@mail.gmail.com>
	<OF748A4720.94B5A869-ON65257695.00267BA3-65257695.0027EDC4@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yinghai@kernel.org, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	avorontsov@ru.mvista.com, Sandeep.Kumar@freescale.com,
	galak@kernel.crashing.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42935
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751428AbZLXFLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2009 00:11:55 -0500
In-Reply-To: <OF748A4720.94B5A869-ON65257695.00267BA3-65257695.0027EDC4@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar2 <krkumar2@in.ibm.com>
Date: Wed, 23 Dec 2009 12:57:26 +0530

> Also, I was looking at other providers of select_queue and found:
> 
> u16 gfar_select_queue(struct net_device *dev, struct sk_buff *skb)
> {
>         return skb_get_queue_mapping(skb);
> }
> 
> How can this be correct (driver supports upto 8 txq's). Unless txq=0 for
> xmits of all locally
> generated packets is fine.

This must be fixed.  As you note the queue mapping is only set
for forwarding/bridging cases.

There is zero reason for this driver to have it's own select_queue
function, so the fix seems to simply remove this thing altogether.

Some gianfar developer please prepare such a patch, thanks.
