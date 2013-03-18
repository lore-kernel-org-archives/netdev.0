From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] packet: packet fanout rollover during
 socket overload
Date: Mon, 18 Mar 2013 16:10:49 -0700
Message-ID: <1363648249.21184.11.camel@edumazet-glaptop>
References: <1363648051-5976-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:44526 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751654Ab3CRXKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 19:10:51 -0400
Received: by mail-pb0-f50.google.com with SMTP id up1so6809431pbc.37
        for <netdev@vger.kernel.org>; Mon, 18 Mar 2013 16:10:51 -0700 (PDT)
In-Reply-To: <1363648051-5976-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-18 at 19:07 -0400, Willem de Bruijn wrote:
> Minimize packet drop in a fanout group. If one socket is full,
> roll over packets to another from the group. Maintain flow
> affinity during normal load using an rxhash fanout policy, while
> dispersing unexpected traffic storms that hit a single cpu, such
> as spoofed-source DoS flows. Rollover breaks affinity for flows
> arriving at saturated sockets during those conditions.
> 
> The patch adds a fanout policy ROLLOVER that rotates between sockets,
> filling each socket before moving to the next. It also adds a fanout
> flag ROLLOVER. If passed along with any other fanout policy, the
> primary policy is applied until the chosen socket is full. Then,
> rollover selects another socket, to delay packet drop until the
> entire system is saturated.
> 
> Probing sockets is not free. Selecting the last used socket, as
> rollover does, is a greedy approach that maximizes chance of
> success, at the cost of extreme load imbalance. In practice, with
> sufficiently long queues to absorb bursts, sockets are drained in
> parallel and load balance looks uniform in `top`.
> 
> To avoid contention, scales counters with number of sockets and
> accesses them lockfree. Values are bounds checked to ensure
> correctness.
> 
> Tested using an application with 9 threads pinned to CPUs, one socket
> per thread and sufficient busywork per packet operation to limits each
> thread to handling 32 Kpps. When sent 500 Kpps single UDP stream
> packets, a FANOUT_CPU setup processes 32 Kpps in total without this
> patch, 270 Kpps with the patch. Tested with read() and with a packet
> ring (V1).
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---

Reviewed-by: Eric Dumazet <edumazet@google.com>
