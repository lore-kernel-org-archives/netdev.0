From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net] net: diag: support v4mapped sockets in inet_diag_find_one_icsk()
Date: Wed, 20 Jan 2016 18:37:22 -0800
Message-ID: <CAKD1Yr2mJ6XFM4BpR+dRDM9_zVQHQ3NxYD5nHNPWinNsNTHs5g@mail.gmail.com>
References: <1453335901.1223.337.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:34002 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499AbcAUChm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 21:37:42 -0500
Received: by mail-yk0-f172.google.com with SMTP id a85so33413063ykb.1
        for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 18:37:42 -0800 (PST)
In-Reply-To: <1453335901.1223.337.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 20, 2016 at 4:25 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Lorenzo reported that we could not properly find v4mapped sockets
> in inet_diag_find_one_icsk(). This patch fixes the issue.
>
> Reported-by: Lorenzo Colitti <lorenzo@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

This fixes the problem for me. I tested that SOCK_DESTROY (which uses
inet_diag_find_one_icsk) can successfully find/close the following
AF_INET6 sockets:

- Listen sockets bound to either :: or ::ffff:0.0.0.0
- Accepted IPv4 connections on sockets bound to either :: or ::ffff:0.0.0.0
- Active IPv4 connections

Acked-by: Lorenzo Colitti <lorenzo@google.com>
