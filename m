From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: ipv6: Fix ping to link-local addresses.
Date: Mon, 08 Aug 2016 22:20:30 -0700 (PDT)
Message-ID: <20160808.222030.1314134961786852070.davem@davemloft.net>
References: <1470642127-574-1-git-send-email-lorenzo@google.com>
	<20160808.143500.473355495580691289.davem@davemloft.net>
	<CAKD1Yr25UUNOANnUD+cCszA2HfoPrsEPxaGqgqBBBG_wcs1tGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org, ek@google.com,
	hideaki.yoshifuji@miraclelinux.com
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:32828 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914AbcHIFUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 01:20:37 -0400
Received: by mail-pf0-f196.google.com with SMTP id i6so225928pfe.0
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 22:20:37 -0700 (PDT)
In-Reply-To: <CAKD1Yr25UUNOANnUD+cCszA2HfoPrsEPxaGqgqBBBG_wcs1tGg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Tue, 9 Aug 2016 10:00:25 +0900

> Note that pretty much every sendmsg codepath allows other data to take
> precedence over sk_bound_dev_if:
> 
> - udpv6_sendmsg: if sin6_scope_id specified on a scoped address
> - rawv6_sendmsg: if sin6_scope_id specified on a scoped address
> - l2tp_ip6_sendmsg: if sin6_scope_id specified on a scoped address
> - ip_cmsg_send: if IP_PKTINFO or IPV6_PKTINFO specified
> 
> What should I do about those? -EINVAL? Ignore the conflicting data? Leave as is?

That's a good point, I guess this needs some more thought.
