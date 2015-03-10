From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bcmgenet: collect Rx discarded packet
 count
Date: Tue, 10 Mar 2015 17:29:05 -0400 (EDT)
Message-ID: <20150310.172905.949955668286642370.davem@davemloft.net>
References: <20150310191800.C5812220365@puck.mtv.corp.google.com>
	<54FF4973.30306@gmail.com>
	<CAGXr9JEnP50ff+CzVVoBXa6iRKdbCKoaaZv0Zx-ndVN_gorKSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org, jaedon.shin@gmail.com
To: pgynther@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60922 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932126AbbCJV3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 17:29:09 -0400
In-Reply-To: <CAGXr9JEnP50ff+CzVVoBXa6iRKdbCKoaaZv0Zx-ndVN_gorKSw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther <pgynther@google.com>
Date: Tue, 10 Mar 2015 13:52:32 -0700

> It is a rare event that discards > 0. Thus, the extra register write
> happens very infrequently.
> 
> And, writing 0 to RDMA_PROD_INDEX does not reset the producer index
> bits 15:0 that are used in Rx processing.

You can defer the write until you see the 0xffff saturation value.

Or, perhaps, half the saturation value.

Anything is better than doing it on any discard, because this overhead
will make whatever is causing the cpu to be backlogged even worse.
