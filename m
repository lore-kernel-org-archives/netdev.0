From: Zhouyi Zhou <zhouzhouyi@gmail.com>
Subject: Re: kernel panic in fib6_age (linux-3.6.6) and sugguested fix
Date: Thu, 7 Mar 2013 14:58:42 +0800
Message-ID: <CAABZP2xW7z+AXReRHfiMyrSP6gBkzPJOG4oAm6xZK+KCsBYvdw@mail.gmail.com>
References: <CAABZP2xs4qm7j75Hu5BaXuWOF3ddzrZPJxbTGhxpOvwHxA75Uw@mail.gmail.com>
	<5137FB4C.60006@gmail.com>
	<CAABZP2ztW5=1i2tzwqVF921tmrkrUws0pcKUBWNYAoC0MYXk4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f173.google.com ([209.85.210.173]:55863 "EHLO
	mail-ia0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751039Ab3CGG6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 01:58:42 -0500
Received: by mail-ia0-f173.google.com with SMTP id h37so127244iak.18
        for <netdev@vger.kernel.org>; Wed, 06 Mar 2013 22:58:42 -0800 (PST)
In-Reply-To: <CAABZP2ztW5=1i2tzwqVF921tmrkrUws0pcKUBWNYAoC0MYXk4A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> How about this one below? without modifying the return value:
>                         __u8 neigh_flags = 0;
>
>
>                         neigh = dst_neigh_lookup(&rt->dst,
> &rt->rt6i_gateway);
> -                       if (neigh) {
> +                       if (!IS_ERR(neigh)) {
>
>                                 neigh_flags = neigh->flags;
>                                 neigh_release(neigh);
>                         }
you are correct, this one avoid breaking out of the process of the fib
table traveling

Zhouyi
