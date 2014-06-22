From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: Re: [PATCH net-next v2 8/8] enic: do tx cleanup in napi poll
Date: Sun, 22 Jun 2014 12:55:30 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1406221250230.1311@ws.cisco>
References: <1403077088-4818-1-git-send-email-_govind@gmx.com> <1403077088-4818-9-git-send-email-_govind@gmx.com> <20140621.152440.2152576710542860161.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: _govind@gmx.com, netdev@vger.kernel.org, ssujith@cisco.com,
	benve@cisco.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:62176 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751027AbaFVH0M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Jun 2014 03:26:12 -0400
In-Reply-To: <20140621.152440.2152576710542860161.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sat, 21 Jun 2014, David Miller wrote:
> It is recommended that TX work not count against the quota.
>
> The cost of TX packet liberation is a minute percentage of what it
> costs to process an RX frame.  Furthermore, that SKB freeing makes
> memory available for other paths in the stack.
>
> So please, just unconditionally purge the entire set of pending TX
> queue completion entries without regards to the passed in NAPI quota
> value at all.
>

So I should ignore the budget value and clean all packets possible. And what
should the NAPIs return value should be? I can not be > 64 right?

Or should I netif_napi_add() with highest value possible? For enic its 4096.

Thanks
