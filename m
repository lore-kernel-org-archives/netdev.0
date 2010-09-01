From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xps-mq: Transmit Packet Steering for multiqueue
Date: Wed, 01 Sep 2010 09:09:35 -0700 (PDT)
Message-ID: <20100901.090935.63038425.davem@davemloft.net>
References: <alpine.DEB.1.00.1008222233530.31382@pokey.mtv.corp.google.com>
	<20100823105933.27cd0b80@nehalam>
	<AANLkTin2rmcsxHi6+bFEUykhrkoWs--hrisAx_v__k1D@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33396
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755002Ab0IAQJS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 12:09:18 -0400
In-Reply-To: <AANLkTin2rmcsxHi6+bFEUykhrkoWs--hrisAx_v__k1D@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 1 Sep 2010 08:41:14 -0700

>> Why don't we do this in the normal transmit processing.
>> There is already so much policy mechanism filters/actions/qdisc that
>> doing it in higher level is fighting against these.
>>
> Are you proposing that TX queue selection be done in the qdiscs?  The
> queue has to be selected before taking the lock (cannot afford taking
> a lock over the whole interface).  This would necessitate moving the
> locking and probably rearranging a lot of the xmit code around that.

Right, we really have to pick queues before entering the qdisc for
the full benefit of lock seperation.
