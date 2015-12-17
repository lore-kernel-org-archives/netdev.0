From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [Patch net] net: check both type and procotol for tcp sockets
Date: Thu, 17 Dec 2015 10:52:02 -0500
Message-ID: <CAF=yD-+DHDUdU2njA32eTP1MMtHwp_mTt=hSE+-wVvp0ByuWLA@mail.gmail.com>
References: <1450337944-22834-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:35827 "EHLO
	mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934845AbbLQPwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 10:52:43 -0500
Received: by mail-lf0-f43.google.com with SMTP id l133so54390311lfd.2
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2015 07:52:43 -0800 (PST)
In-Reply-To: <1450337944-22834-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2015 at 2:39 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> Dmitry reported the following out-of-bound access:
>
> Call Trace:
>  [<ffffffff816cec2e>] __asan_report_load4_noabort+0x3e/0x40
> mm/kasan/report.c:294
>  [<ffffffff84affb14>] sock_setsockopt+0x1284/0x13d0 net/core/sock.c:880
>  [<     inline     >] SYSC_setsockopt net/socket.c:1746
>  [<ffffffff84aed7ee>] SyS_setsockopt+0x1fe/0x240 net/socket.c:1729
>  [<ffffffff85c18c76>] entry_SYSCALL_64_fastpath+0x16/0x7a
> arch/x86/entry/entry_64.S:185
>
> This is because we mistake a raw socket as a tcp socket.
> We should check both sk->sk_type and sk->sk_protocol to ensure
> it is a tcp socket.
>
> Willem points out __skb_complete_tx_timestamp() needs to fix as well.
>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Acked-by: Willem de Bruijn <willemb@google.com>

Thanks for fixing both cases at once.
