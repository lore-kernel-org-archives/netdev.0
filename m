From: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Subject: Re: [PATCH net-next 3/3] sunvnet: Schedule maybe_tx_wakeup as a tasklet from ldc_rx path
Date: Tue, 12 Aug 2014 22:14:09 -0700
Message-ID: <8BE2AE04-EF39-45A0-9AB4-15F5160C1449@oracle.com>
References: <20140812.151352.2235795686370279748.davem@davemloft.net> <20140813015817.GA13600@oracle.com> <163B73C6-95EF-4398-B399-ECD5B95F5EC8@oracle.com> <20140812.213157.60038488349789826.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: sowmini.varadhan@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:47123 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751494AbaHMFOO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 01:14:14 -0400
In-Reply-To: <20140812.213157.60038488349789826.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Aug 12, 2014, at 9:31 PM, David Miller <davem@davemloft.net> wrote:

> From: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
> Date: Tue, 12 Aug 2014 21:26:28 -0700
> 
>> One important point to keep in mind that packets to different peers shouldn't
>> be blocked by one blocked peer. Any flow controlling or dropping of the packets
>> needs to be done on a per-port basis.
> 
> Until we use a big hammer and reset the LDC channel of that peer, we
> _absolutely_ should not reorder traffic and send to non-stuck peers.

The packet ordering requirement applies only for packets destined to
a specific destination. The packets to different destinations can flow
as long as they do not cause ordering issues. In case of sunvnet, 
each peer except the switch-port would be for a specific destination,
so sending packets to other ports would not result in re-ordering of the packets.

Even if the peer to peer LDC is the one that is blocked then disconnecting
that LDC channel and sending the packets via switch-port would not be
expected to change the order of the packet as the LDC reset is expect
to drop all packets in the ring so far.  

-Raghuram
> 
> A networking stack should avoid packet reordering in all cases when it
> has the ability to do so, and sending packets which came in later to
> unstuck peers when there are older packets still pending to the stuck
> peer violates that requirement.
