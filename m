From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/9] net: add skb_orphan_frags to copy aside frags with
 destructors
Date: Thu, 03 May 2012 13:55:32 -0400 (EDT)
Message-ID: <20120503.135532.1038384417514973419.davem@davemloft.net>
References: <1336056915.20716.96.camel@zakaz.uk.xensource.com>
	<1336056971-7839-7-git-send-email-ian.campbell@citrix.com>
	<20120503154142.GB27671@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45826 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753784Ab2ECRzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 13:55:39 -0400
In-Reply-To: <20120503154142.GB27671@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 3 May 2012 18:41:43 +0300

> On Thu, May 03, 2012 at 03:56:09PM +0100, Ian Campbell wrote:
>> This should be used by drivers which need to hold on to an skb for an extended
>> (perhaps unbounded) period of time. e.g. the tun driver which relies on
>> userspace consuming the skb.
>> 
>> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
>> Cc: mst@redhat.com
> 
> 
> Right. But local sockets queue at socket forever as well.
> I think this should be called in skb_set_owner_r?
> 
> This might somewhat penalize speed for local clients in the name
> of correctness but these are rare so being correct is
> more important I think.

But, on the other hand, putting the check into skb_set_owner_r() is a
not so nice test to have in the fast path of every socket receive.
