From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] ipv6 addrconf: disallow rtr_solicits < -1
Date: Tue, 4 Oct 2016 15:40:30 +0900
Message-ID: <CANP3RGdVquyFe1VA2mKMC1HNgnXPhmpsv45R-7P6boWCb8oC2A@mail.gmail.com>
References: <1475476917-17382-1-git-send-email-zenczykowski@gmail.com> <20161004.003831.2056791273400961514.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux NetDev <netdev@vger.kernel.org>, Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f169.google.com ([209.85.213.169]:35299 "EHLO
        mail-yb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751127AbcJDGkb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 02:40:31 -0400
Received: by mail-yb0-f169.google.com with SMTP id 184so26552089yby.2
        for <netdev@vger.kernel.org>; Mon, 03 Oct 2016 23:40:31 -0700 (PDT)
In-Reply-To: <20161004.003831.2056791273400961514.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Please remove the const qualifier and the casts to be consistent
> with how we handle this elsewhere.
>
> Thanks.

I can of course trivially make that change.

But:

(on net-next/master)
git grep 'extra[12].*=.*\(void *[*]\)'

currently finds 45 matches, and this patch adds a 46th.

In particular there's a ton of such examples in:
  drivers/parport/procfs.c
  kernel/sysctl.c
  net/rxrpc/sysctl.c
  security/keys/sysctl.c

There's also the 2 that were added to:
  net/ipv6/addrconf.c (ie. same file as this patch)
in my previous patch set.

Should I also remove void * from those as well?

Should this be left as is?

Marking it explicitly as const gets the constants into the rodata
section which is cpu page table masked to be read-only so it seems
much safer/better...

- Maciej
