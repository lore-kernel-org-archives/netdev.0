From: Yuchung Cheng <ycheng@google.com>
Subject: Re: Issues related to TCP Fast Open flags: TFO_SERVER_COOKIE_NOT_CHKED
 and TFO_SERVER_WO_SOCKOPT2
Date: Mon, 15 Aug 2016 09:52:40 -0700
Message-ID: <CAK6E8=fakba_v3mZBXBSaeDbsQBjfXcdoYRTbkmsOhcnsZ5iXQ@mail.gmail.com>
References: <58f77827-c57c-0602-255f-a76fdd3cd472@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Piotr Jurkiewicz <piotr.jerzy.jurkiewicz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:36481 "EHLO
	mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752863AbcHOQxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 12:53:22 -0400
Received: by mail-it0-f47.google.com with SMTP id e63so11463584ith.1
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 09:53:21 -0700 (PDT)
In-Reply-To: <58f77827-c57c-0602-255f-a76fdd3cd472@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 13, 2016 at 4:05 PM, Piotr Jurkiewicz
<piotr.jerzy.jurkiewicz@gmail.com> wrote:
> 1. Handling of TFO_SERVER_COOKIE_NOT_CHKED flag was removed back in 2014,
> but this flag is still mentioned in the documentation:
>
> Documentation/networking/ip-sysctl.txt:
>         0x100: Accept SYN data w/o validating the cookie.
>
> 2. There is no explanation how TFO_SERVER_WO_SOCKOPT1 and
> TFO_SERVER_WO_SOCKOPT2 differ, the docs only say:
>
> Documentation/networking/ip-sysctl.txt:
>         0x400/0x800: Enable Fast Open on all listeners regardless of the
>            TCP_FASTOPEN socket option. The two different flags designate two
>            different ways of setting max_qlen without the TCP_FASTOPEN
> socket
>            option.
>
> 3. When TFO_SERVER_WO_SOCKOPT2 flag is set, the fastopenq.max_qlen is set to
> the value of sysctl bitmap containing flags (sysctl_tcp_fastopen), what is
> (at least for me) completely irrational and I believe is a bug:
>
> net/ipv4/af_inet.c:
> 225                         else if ((sysctl_tcp_fastopen &
> 226                                   TFO_SERVER_WO_SOCKOPT2) != 0)
> 227                                 fastopen_queue_tune(sk,
> 228                                     ((uint)sysctl_tcp_fastopen) >> 16);
Thanks for pointing these issues out. The document indeed needs work.

TFO_SERVERS_WO_SOCKEOPT2 was used for debugging purposes that we
forget to clean up before upstream. Here is my plan:

1) send a patch to remove this opaque/buggy internal debugging option
2) update the ip-sysctl, perhaps update tcp option man pages

How does that sound?
