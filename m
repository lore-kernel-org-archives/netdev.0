From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Thu, 29 Jun 2006 17:44:41 -0700
Message-ID: <44A473F9.7030601@candelatech.com>
References: <1151626099.8922.64.camel@jzny2>	<20060629.171215.112621072.davem@davemloft.net>	<1151627180.8922.81.camel@jzny2> <20060629.172948.59656719.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, tgraf@suug.ch, kaber@trash.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:60122 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1751364AbWF3ApX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 20:45:23 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060629.172948.59656719.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:

> I'm saying that, we don't need the refcount, just setting
> the skb->input_index thing, unless someone actually cares
> about the input device.
> 
> As long as the packet hits not paths that care about the
> SKB input device, no atomic refcounts are taken.  It's
> just an integer sitting there in the SKB.

Also, if this lookup is to be done multiple times per skb, we could
do the lookup once and grab the ref at that time and store the
pointer in the skb.  If you wanted to be truly horible about it..could
use a 64-bit input_index and copy the pointer there (and set a flag somewhere
noting it is no longer an index but a pointer) so save the extra
64-bits.

Ben


> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

