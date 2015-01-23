From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ping: Fix race in free in receive path
Date: Fri, 23 Jan 2015 15:07:43 -0800
Message-ID: <1422054463.29618.12.camel@edumazet-glaptop2.roam.corp.google.com>
References: <45fab13fce077924f957cba84ba20ba4.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:49882 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561AbbAWXHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 18:07:45 -0500
Received: by mail-ie0-f172.google.com with SMTP id rd18so176102iec.3
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 15:07:44 -0800 (PST)
In-Reply-To: <45fab13fce077924f957cba84ba20ba4.squirrel@www.codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-01-23 at 22:26 +0000, subashab@codeaurora.org wrote:
> An exception is seen in ICMP ping receive path where the skb
> destructor sock_rfree() tries to access a freed socket. This happens
> because ping_rcv() releases socket reference with sock_put() and this
> internally frees up the socket. Later icmp_rcv() will try to free the
> skb and as part of this, skb destructor is called and which leads
> to a kernel panic as the socket is freed already in ping_rcv().
...
> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
> Cc: Eric Dumazet <edumazet@google.com>
> ---

Thanks !

Signed-off-by: Eric Dumazet <edumazet@google.com>
