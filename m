From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix tx queue selection for bridged devices
 implementing select_queue
Date: Mon, 06 Sep 2010 17:48:16 -0700 (PDT)
Message-ID: <20100906.174816.102563052.davem@davemloft.net>
References: <1283517596-2382-1-git-send-email-helmut.schaa@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net,
	krkumar2@in.ibm.com
To: helmut.schaa@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56730
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752968Ab0IGAr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 20:47:59 -0400
In-Reply-To: <1283517596-2382-1-git-send-email-helmut.schaa@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Helmut Schaa <helmut.schaa@googlemail.com>
Date: Fri,  3 Sep 2010 14:39:56 +0200

> When a net device is implementing the select_queue callback and is part of
> a bridge, frames coming from the bridge already have a tx queue associated
> to the socket (introduced in commit a4ee3ce3293dc931fab19beb472a8bde1295aebe,
> "net: Use sk_tx_queue_mapping for connected sockets"). The call to
> sk_tx_queue_get will then return the tx queue used by the bridge instead
> of calling the select_queue callback.
> 
> In case of mac80211 this broke QoS which is implemented by using the
> select_queue callback. Furthermore it introduced problems with rt2x00
> because frames with the same TID and RA sometimes appeared on different
> tx queues which the hw cannot handle correctly.
> 
> Fix this by always calling select_queue first if it is available and only
> afterwards use the socket tx queue mapping.
> 
> Signed-off-by: Helmut Schaa <helmut.schaa@googlemail.com>

Applied to net-2.6, thanks Helmut.
