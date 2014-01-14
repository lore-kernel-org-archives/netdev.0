From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] inet_diag: fix inet_diag_dump_icsk() to use
 correct state for timewait sockets
Date: Mon, 13 Jan 2014 22:36:09 -0800 (PST)
Message-ID: <20140113.223609.740104415435674658.davem@davemloft.net>
References: <1389386085-22659-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41074 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbaANGgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 01:36:10 -0500
In-Reply-To: <1389386085-22659-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Fri, 10 Jan 2014 15:34:45 -0500

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

Applied, thanks.
