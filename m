From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 1/2] tcp: uniform the set up of sockets
 after successful connection
Date: Thu, 05 Oct 2017 21:10:43 -0700 (PDT)
Message-ID: <20171005.211043.2125306522607618573.davem@davemloft.net>
References: <20171004170344.132339-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, ncardwell@google.com,
        edumazet@google.com
To: weiwan@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57168 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750781AbdJFEKo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 00:10:44 -0400
In-Reply-To: <20171004170344.132339-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>
Date: Wed,  4 Oct 2017 10:03:44 -0700

> From: Wei Wang <weiwan@google.com>
> 
> Currently in the TCP code, the initialization sequence for cached
> metrics, congestion control, BPF, etc, after successful connection
> is very inconsistent. This introduces inconsistent bevhavior and is
> prone to bugs. The current call sequence is as follows:
 ...
> This commit uniforms the above functions to have the following sequence:
>         tcp_mtup_init(sk);
>         icsk->icsk_af_ops->rebuild_header(sk);
>         tcp_init_metrics(sk);
>         tcp_call_bpf(sk, BPF_SOCK_OPS_ACTIVE/PASSIVE_ESTABLISHED_CB);
>         tcp_init_congestion_control(sk);
>         tcp_init_buffer_space(sk);
> This sequence is the same as the (1) active case. We pick this sequence
> because this order correctly allows BPF to override the settings
> including congestion control module and initial cwnd, etc from
> the route, and then allows the CC module to see those settings.
> 
> Suggested-by: Neal Cardwell <ncardwell@google.com>
> Tested-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Wei Wang <weiwan@google.com>
> Acked-by: Neal Cardwell <ncardwell@google.com>
> Acked-by: Yuchung Cheng <ycheng@google.com>
> Acked-by: Eric Dumazet <edumazet@google.com>

Nice change, applied, thanks.
