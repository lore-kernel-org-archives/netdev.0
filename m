From: Brendan Gregg <brendan.d.gregg@gmail.com>
Subject: Re: [Patch net-next v3] tcp: add a tracepoint for tcp retransmission
Date: Fri, 13 Oct 2017 13:50:44 -0700
Message-ID: <CAE40pdcdcLw9pdDkVEPFKvCLe0FcQzsV4vU0K-3YbNr1gS0Y6g@mail.gmail.com>
References: <20171013200316.28561-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Neal Cardwell <ncardwell@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:55725 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751378AbdJMUvQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 16:51:16 -0400
Received: by mail-wm0-f66.google.com with SMTP id u138so24059703wmu.4
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 13:51:15 -0700 (PDT)
In-Reply-To: <20171013200316.28561-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 13, 2017 at 1:03 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> We need a real-time notification for tcp retransmission
> for monitoring.
>
> Of course we could use ftrace to dynamically instrument this
> kernel function too, however we can't retrieve the connection
> information at the same time, for example perf-tools [1] reads
> /proc/net/tcp for socket details, which is slow when we have
> a lots of connections.
>
> Therefore, this patch adds a tracepoint for __tcp_retransmit_skb()
> and exposes src/dst IP addresses and ports of the connection.
> This also makes it easier to integrate into perf.
>
> Note, I expose both IPv4 and IPv6 addresses at the same time:
> for a IPv4 socket, v4 mapped address is used as IPv6 addresses,
> for a IPv6 socket, LOOPBACK4_IPV6 is already filled by kernel.
> Also, add sk and skb pointers as they are useful for BPF.

Thanks, a TCP retransmit tracepoint would be great. (tcp_set_state
would be highly useful too, which Alexei already has in his list).

Should skp->__sk_common.skc_state be included in the format string, so
we don't have to always dig it out of the skaddr? For retransmits I
always want to know the TCP state, to determine if it is ESTABLISHED
(packet drop) or SYN_SENT (backlog full) or something else.

We probably need a tracepoint for tcp_send_loss_probe() (TLP) as well,
for tracing at the same time as retransmits (like my tools do), but
that can be added later.

Brendan
