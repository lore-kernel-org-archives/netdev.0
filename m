From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH -next] ipv6: reject locally assigned nexthop addresses
Date: Thu, 21 May 2015 01:55:29 +0200
Message-ID: <1432166129.744347.274292401.7D68B8C1@webmail.messagingengine.com>
References: <1432160741-3588-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:40755 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753554AbbETXza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 19:55:30 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 727C5208D2
	for <netdev@vger.kernel.org>; Wed, 20 May 2015 19:55:29 -0400 (EDT)
In-Reply-To: <1432160741-3588-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 21, 2015, at 00:25, Florian Westphal wrote:
> ip -6 addr add dead::1/128 dev eth0
> sleep 5
> ip -6 route add default via dead::1/128
> -> fails
> ip -6 addr add dead::1/128 dev eth0
> ip -6 route add default via dead::1/128
> -> succeeds
> 
> reason is that if (nonsensensical) route above is added,
> dead::1 is still subject to DAD, so the route lookup will
> pick eth0 as outdev due to the prefix route that is added before
> DAD work is started.
> 
> Add explicit test that checks if nexthop gateway is a local address.
> 
> Link: https://bugzilla.redhat.com/show_bug.cgi?id=1167969

Should hopefully be public soon. :/

> Signed-off-by: Florian Westphal <fw@strlen.de>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks!
