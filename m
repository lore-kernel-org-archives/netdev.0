From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: remove useless check in napi_gro_frags()
Date: Fri, 20 Nov 2015 14:59:14 -0500 (EST)
Message-ID: <20151120.145914.2164877853297235919.davem@davemloft.net>
References: <1447965199.22599.252.camel@edumazet-glaptop2.roam.corp.google.com>
	<f7tfv01pulb.fsf@aconole.bos.csb>
	<1447969425.22599.254.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aconole@redhat.com, bjorn@mork.no, alexei.starovoitov@gmail.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34649 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751836AbbKTT7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 14:59:17 -0500
In-Reply-To: <1447969425.22599.254.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 19 Nov 2015 13:43:45 -0800

> On Thu, 2015-11-19 at 16:06 -0500, Aaron Conole wrote:
> 
>> >
>> 
>> Would the following be an appropriate change in addition to the one
>> you've posted, then? If so I can repost as a formal patch, if you'd
>> like. At present, there's only one user of napi_frags_skb(), and your
>> patch removes the NULL check. If this can really only be the result of
>> buggy driver, then perhaps we should just call out the bug?
> 
> Lets mark my patch as "premature" optimization, and revisit whole thing
> after audit of the 10 drivers using this interface ;)

Also BUG_ON() is way too large a hammer.

An attempt to continue should be made in some way, so that person
inspecting the message and still have a network and work on fixing
the driver after the check triggers :-)
