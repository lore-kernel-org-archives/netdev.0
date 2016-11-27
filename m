From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Crash due to mutex genl_lock called from RCU context
Date: Sat, 26 Nov 2016 18:08:28 -0800
Message-ID: <CAM_iQpU+7arMOHSwDhE5npH_82R9LTNrmny6jK1H-fkW2+9Jcg@mail.gmail.com>
References: <c669cd06c3e50febd95b5ed4aaa78532@codeaurora.org>
 <1480133493.8455.584.camel@edumazet-glaptop3.roam.corp.google.com> <1480136078.8455.589.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: subashab@codeaurora.org, Thomas Graf <tgraf@suug.ch>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:33328 "EHLO
        mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752677AbcK0CIt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2016 21:08:49 -0500
Received: by mail-io0-f181.google.com with SMTP id j65so178723083iof.0
        for <netdev@vger.kernel.org>; Sat, 26 Nov 2016 18:08:49 -0800 (PST)
In-Reply-To: <1480136078.8455.589.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 25, 2016 at 8:54 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Oh well, this wont work, since sk->sk_destruct will be called from RCU
> callback.
>
> Grabbing the mutex should not be done from netlink_sock_destruct() but
> from netlink_release()

But you also change the behavior of cb.done(), currently it is called when the
last sock ref is gone, with your patch it is called when the first
sock is closed.
No?

I don't see why we need to get genl_lock in ->done() here, because we are
already the last sock using it and module ref protects the ops from being
removed via module, seems we are pretty safe without any lock.
