From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next RFC] Generic XDP
Date: Sun, 09 Apr 2017 12:24:07 -0700 (PDT)
Message-ID: <20170409.122407.991589103284660026.davem@davemloft.net>
References: <20170408.200721.109499285021338999.davem@davemloft.net>
        <20170409134655.GA2133@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xdp-newbies@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59290 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752376AbdDITYO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Apr 2017 15:24:14 -0400
In-Reply-To: <20170409134655.GA2133@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Sun, 9 Apr 2017 15:46:55 +0200

>> +	switch (act) {
>> +	case XDP_PASS:
>> +	case XDP_TX:
>> +		break;
>> +
>> +	default:
>> +		bpf_warn_invalid_xdp_action(act);
> 
> Hi David
> 
> You might want to put a /* fall through */ comment here, just to
> prevent newbies from submitting patches moving the default clause to
> the end.

Probably need two, ala:

	default:
		bpf_warn_invalid_xdp_action(act);
		/* fall through */
	case XDP_ABORTED:
		trace_xdp_exception(skb->dev, xdp_prog, act);
		/* fall through */
	case XDP_DROP:
	do_drop:
		kfree_skb(skb);
		break;

So that's what I've done.

Thanks!
