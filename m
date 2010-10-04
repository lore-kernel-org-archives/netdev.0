From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: ixgbe: normalize frag_list usage
Date: Mon, 04 Oct 2010 12:49:53 -0700
Message-ID: <4CAA2FE1.6030900@intel.com>
References: <20101003.235400.229759758.davem@davemloft.net>	<4CAA1722.7070405@intel.com> <20101004.113258.212671454.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:16614 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754622Ab0JDTt4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Oct 2010 15:49:56 -0400
In-Reply-To: <20101004.113258.212671454.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: Mon, 04 Oct 2010 11:04:18 -0700
> 
>> This will not work for RSC due to the fact that it assumes only one
>> RSC context is active per ring and that is not the case.  There can be
>> multiple RSC combined flows interlaced on the ring.
> 
> Thanks for looking at this Alexander.
> 
> I must have mis-understood what the current code is doing.
> 
> It looked like RSC packets always show up in-order in the RX ring.
> 
> And that they are scanned for by simply combining any sequence of
> non-EOP packets up to and including the final EOP one into a frag
> list.
> 
> Are the RSC packets are identified via something else entirely?

They show up in order, but they are not necessarily linear.  You can 
have other packets show up in the middle of the flow and RSC just jumps 
over them.  The determination for the jump is handled via nextp in 
ixgbe_clean_rx_irq.

I'll look into this and see if I can come up with a counter-proposal 
patch based on the suggestions I was making.  The key item though is 
that the tail would need some means of referencing head which I think 
can probably be accomplished via skb->next.

Thanks,

Alex






