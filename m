From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] inet_diag: fix inet_diag_dump_icsk() to use correct
 state for timewait sockets
Date: Fri, 10 Jan 2014 13:32:33 -0800
Message-ID: <1389389553.31367.143.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389386085-22659-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f180.google.com ([209.85.161.180]:63350 "EHLO
	mail-gg0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751356AbaAJVci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 16:32:38 -0500
Received: by mail-gg0-f180.google.com with SMTP id q3so826929gge.39
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 13:32:36 -0800 (PST)
In-Reply-To: <1389386085-22659-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-01-10 at 15:34 -0500, Neal Cardwell wrote:
> Fix inet_diag_dump_icsk() to reflect the fact that both TCP_TIME_WAIT
> and TCP_FIN_WAIT2 connections are represented by inet_timewait_sock
> (not just TIME_WAIT), and for such sockets the tw_substate field holds
> the real state, which can be either TCP_TIME_WAIT or TCP_FIN_WAIT2.
> 
> This brings the inet_diag state-matching code in line with the field
> it uses to populate idiag_state. This is also analogous to the info
> exported in /proc/net/tcp, where get_tcp4_sock() exports sk->sk_state
> and get_timewait4_sock() exports tw->tw_substate.
> 
> Before fixing this, (a) neither "ss -nemoi" nor "ss -nemoi state
> fin-wait-2" would return a socket in TCP_FIN_WAIT2; and (b) "ss -nemoi
> state time-wait" would also return sockets in state TCP_FIN_WAIT2.
> 
> This is an old bug that predates 05dbc7b ("tcp/dccp: remove twchain").
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
