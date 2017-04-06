From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net 1/1] net: tcp: Don't increase the TCP_MIB_OUTRSTS when
 fail to transmit RST
Date: Thu, 6 Apr 2017 10:00:54 -0400
Message-ID: <CADVnQymp9X3EwmiiocNHU8bQpg7Wb7FvGr4SduKjhLoTv35zMA@mail.gmail.com>
References: <1491485709-8269-1-git-send-email-gfree.wind@foxmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Patrick McHardy <kaber@trash.net>,
        Netdev <netdev@vger.kernel.org>, Gao Feng <fgao@ikuai8.com>
To: Gao Feng <gfree.wind@foxmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:36058 "EHLO
        mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934832AbdDFOB0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 10:01:26 -0400
Received: by mail-oi0-f43.google.com with SMTP id r203so52096021oib.3
        for <netdev@vger.kernel.org>; Thu, 06 Apr 2017 07:01:26 -0700 (PDT)
In-Reply-To: <1491485709-8269-1-git-send-email-gfree.wind@foxmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 6, 2017 at 9:35 AM,  <gfree.wind@foxmail.com> wrote:
> From: Gao Feng <fgao@ikuai8.com>
>
> When fail to transmit RST, don't increase TCP_MIB_OUTRSTS in func
> tcp_send_active_reset like the case that it only increases
> LINUX_MIB_TCPABORTFAILED when fail to alloc skb.
>
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---

I would be concerned that this is a change in the semantics of
TCP_MIB_OUTRSTS that might break user-space monitoring tools that rely
on the current semantics. Counting attempted RSTs could be an
important signal to monitor, and it could be quite bad if that signal
is lost or hidden because the machine is so overloaded that the
transmission of the RSTs fails.

Also it would seem to muddy the semantics a bit, since both
tcp_v4_send_reset() and tcp_v6_send_response() currently increment
TCP_MIB_OUTRSTS without regard to whether the transmit actually
succeeded or not.

neal
