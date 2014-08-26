From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] ixgbe: flush when in xmit_more mode and under
 descriptor pressure
Date: Tue, 26 Aug 2014 18:21:20 +0200
Message-ID: <53FCB400.70705@redhat.com>
References: <1409068105-16634-1-git-send-email-dborkman@redhat.com> <53FCAF6C.2070401@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63224 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751879AbaHZQVY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2014 12:21:24 -0400
In-Reply-To: <53FCAF6C.2070401@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2014 06:01 PM, Alexander Duyck wrote:
...
> My thought is to just fold ixgbe_maybe_stop_tx into the if statement.
>
> So it shoudl be:
>   if (!skb->smit_more || ixgbe_maybe_stop_tx(tx_ring, DESC_NEEDED))

Right, that's better; I was just thinking about the DMA error case,
but in that case we release resources back anyway.
