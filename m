From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next-2.6] filter: add a security check at install time
Date: Thu, 2 Dec 2010 16:11:08 +0800
Message-ID: <AANLkTim8+9AA61HwcCQp3p7cSjzaTqerdd4Wtm-28kAt@mail.gmail.com>
References: <1291227893.2856.1039.camel@edumazet-laptop> <20101201.104450.183053379.davem@davemloft.net>
 <1291232937.2856.1042.camel@edumazet-laptop> <20101201.122312.229751364.davem@davemloft.net>
 <1291236342.2856.1057.camel@edumazet-laptop> <AANLkTikK=dy6U0QBjkJxZXeqYXVHwZqjmRhnmYBH-22r@mail.gmail.com>
 <1291272384.2856.1074.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, hagen@jauu.net,
	wirelesser@gmail.com, netdev@vger.kernel.org,
	Dan Rosenberg <drosenberg@vsecurity.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43611 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751951Ab0LBILa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 03:11:30 -0500
Received: by fxm20 with SMTP id 20so882593fxm.19
        for <netdev@vger.kernel.org>; Thu, 02 Dec 2010 00:11:28 -0800 (PST)
In-Reply-To: <1291272384.2856.1074.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 2, 2010 at 2:46 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> [PATCH v2 net-next-2.6] filter: add a security check at install time
>
> We added some security checks in commit 57fe93b374a6
> (filter: make sure filters dont read uninitialized memory) to close a
> potential leak of kernel information to user.
>
> This added a potential extra cost at run time, while we can perform a
> check of the filter itself, to make sure a malicious user doesnt try to
> abuse us.
>
> This patch adds a check_loads() function, whole unique purpose is to
> make this check, allocating a temporary array of mask. We scan the
> filter and propagate a bitmask information, telling us if a load M(K) is
> allowed because a previous store M(K) is guaranteed. (So that
> sk_run_filter() can possibly not read unitialized memory)
>
> Note: this can uncover application bug, denying a filter attach,
> previously allowed.
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Dan Rosenberg <drosenberg@vsecurity.com>
> Cc: Changli Gao <xiaosuo@gmail.com>

It seems correct to me now.

Acked-by: Changli Gao <xiaosuo@gmail.com>

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
