From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net-next] ixgbe: flush when in xmit_more mode and under
 descriptor pressure
Date: Tue, 26 Aug 2014 09:24:16 -0700
Message-ID: <53FCB4B0.10400@intel.com>
References: <1409068105-16634-1-git-send-email-dborkman@redhat.com> <53FCAF6C.2070401@intel.com> <53FCB400.70705@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:56892 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750996AbaHZQYR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2014 12:24:17 -0400
In-Reply-To: <53FCB400.70705@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2014 09:21 AM, Daniel Borkmann wrote:
> On 08/26/2014 06:01 PM, Alexander Duyck wrote:
> ...
>> My thought is to just fold ixgbe_maybe_stop_tx into the if statement.
>>
>> So it shoudl be:
>>   if (!skb->smit_more || ixgbe_maybe_stop_tx(tx_ring, DESC_NEEDED))
> 
> Right, that's better; I was just thinking about the DMA error case,
> but in that case we release resources back anyway.

Actually the order does need to be reversed though.  We should test for
stop_tx first, then xmit_more.  Doing it the other way around would
cause issues as maybe_stop_tx has some other side effects.

Thaks,

Alex
