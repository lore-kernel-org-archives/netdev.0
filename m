From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 3/9] IB/ipoib: Add support for acting as VIF
Date: Wed, 11 Jul 2012 12:59:41 +0300
Message-ID: <4FFD4E8D.7040608@mellanox.com>
References: <1341922569-4118-4-git-send-email-ogerlitz@mellanox.com> <1341923180.3265.5005.camel@edumazet-glaptop> <4FFD33B8.5010604@mellanox.com> <20120711.011912.2063611962030549397.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <roland@kernel.org>, <netdev@vger.kernel.org>, <ali@mellanox.com>,
	<sean.hefty@intel.com>, <erezsh@mellanox.co.il>
To: David Miller <davem@davemloft.net>, <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:46475 "HELO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752522Ab2GKKCb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 06:02:31 -0400
In-Reply-To: <20120711.011912.2063611962030549397.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/11/2012 11:19 AM, David Miller wrote:
> handle_ing() goes into the packet scheduler and qdisc layer, the qdisc 
> layer uses skb->cb[] via struct qdisc_skb_cb

Oh, I knew that the qdisc layer touches skb->cb[] but thought it only 
happens on the TX flow...

Here, the flow Eric pointed on relates to skb which was received by 
IPoIB and is soon going
to be consumed by the eIPoIB driver once the rx handler planted by it is 
executed on the skb.

So even in this "simple" flow we can't assume that qdisc will not 
interfere (why)?

if indeed this is case - I understand that we still can deploy the 
practice used by
ipoib_hard_header which uses struct ipoib_cb, or in other words we can 
use 20 out
of the 48 bytes of the cb, starting from offset of 28 bytes, correct?

Or.
