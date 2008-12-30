From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 9/9 V2] mlx4_en: Multiqueue support
Date: Mon, 29 Dec 2008 18:41:09 -0800 (PST)
Message-ID: <20081229.184109.77843771.davem@davemloft.net>
References: <49589EF5.8070800@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, rdreier@cisco.com, netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41822
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752092AbYL3ClG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2008 21:41:06 -0500
In-Reply-To: <49589EF5.8070800@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Mon, 29 Dec 2008 11:57:09 +0200

> Added a function that performs hashing on the TX traffic.
> The hashing is only done for TCP or UDP packets, all other packets
> are sent to a default queue.
> We use an indirection table with an entry for each hash result.
> For each entry in the table, we hold statistics regarding the stream
> that corresponds to that entry. Packets are then directed to a TX queue
> according to stream's pattern.
> A ring is opened for each queue.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

You are not supposed to provide a driver private function
to hash the traffic.

The generic code already hashes traffic for you, and whatever
it doesn't handle currently will be handled in the future.
The generic code is where gaps should be filled in.

The override function pointer is only for wireless which has
special needs in queue selection that have nothing to do with
flow seperation.

Please resubmit this without your private hashing function.

Thank you.
