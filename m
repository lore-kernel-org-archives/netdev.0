From: Yuchung Cheng <ycheng@google.com>
Subject: Re: TCP fast open using experimental TCP option?
Date: Tue, 25 Apr 2017 14:00:06 -0700
Message-ID: <CAK6E8=dLkNfacnure8OsJxO8sN6=LYH-Pv7R25a9TqWBbat9jg@mail.gmail.com>
References: <CALx6S36L4BbdcASbGNvn6mRMJDhJJ6n8y-uRTgVqteM=f6On6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jerry Chu <hkchu@google.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:36197 "EHLO
        mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1949344AbdDYVAs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 17:00:48 -0400
Received: by mail-it0-f53.google.com with SMTP id g66so27331173ite.1
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 14:00:47 -0700 (PDT)
In-Reply-To: <CALx6S36L4BbdcASbGNvn6mRMJDhJJ6n8y-uRTgVqteM=f6On6A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 12:08 PM, Tom Herbert <tom@herbertland.com> wrote:
> Looks like TCP fast open was using experimental TCP option at some. Is
> this still needed? Technically this violates usage requirements of
> experimental options. Can this be removed now since there is now an
> assigned option number for TFO?
Given that many clients (e.g. android) have not migrated to 4.0
kernels that support TFO opt 34, I would keep it for backward
compatibility for now.

>
>                              case TCPOPT_EXP:
>                                 /* Fast Open option shares code 254 using a
>                                  * 16 bits magic number.
>                                  */
>                                 if (opsize >= TCPOLEN_EXP_FASTOPEN_BASE &&
>                                     get_unaligned_be16(ptr) ==
>                                     TCPOPT_FASTOPEN_MAGIC)
>                                         tcp_parse_fastopen_option(opsize -
>                                                 TCPOLEN_EXP_FASTOPEN_BASE,
>                                                 ptr + 2, th->syn, foc, true);
>                                 break;
