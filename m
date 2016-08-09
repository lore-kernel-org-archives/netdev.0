From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net] net: ipv6: Fix ping to link-local addresses.
Date: Tue, 9 Aug 2016 10:00:25 +0900
Message-ID: <CAKD1Yr25UUNOANnUD+cCszA2HfoPrsEPxaGqgqBBBG_wcs1tGg@mail.gmail.com>
References: <1470642127-574-1-git-send-email-lorenzo@google.com> <20160808.143500.473355495580691289.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Erik Kline <ek@google.com>,
	=?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:36181 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651AbcHIBAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 21:00:47 -0400
Received: by mail-io0-f177.google.com with SMTP id b62so373666216iod.3
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 18:00:46 -0700 (PDT)
In-Reply-To: <20160808.143500.473355495580691289.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 9, 2016 at 6:35 AM, David Miller <davem@davemloft.net> wrote:
> We should always give sk_bound_dev_if the highest priority.
>
> Also, we should amend, not delete, the check against the scope
> ID in the sockaddr.  As explained by YOSHIFUJI Hideaki.

Sure, I can do that.

Note that pretty much every sendmsg codepath allows other data to take
precedence over sk_bound_dev_if:

- udpv6_sendmsg: if sin6_scope_id specified on a scoped address
- rawv6_sendmsg: if sin6_scope_id specified on a scoped address
- l2tp_ip6_sendmsg: if sin6_scope_id specified on a scoped address
- ip_cmsg_send: if IP_PKTINFO or IPV6_PKTINFO specified

What should I do about those? -EINVAL? Ignore the conflicting data? Leave as is?
