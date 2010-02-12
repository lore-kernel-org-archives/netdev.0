From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next PATCH v3 2/3] net: TCP thin linear timeouts
Date: Fri, 12 Feb 2010 06:19:13 -0500
Message-ID: <4B753931.30405@gmail.com>
References: <4B73F30D.6040205@simula.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?UTF-8?B?SWxwbyBK?= =?UTF-8?B?w6RydmluZW4=?=
	<ilpo.jarvinen@helsinki.fi>, Eric Dumazet <eric.dumazet@gmail.com>,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	LKML <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>, damian@tvk.rwth-aachen.de
To: Andreas Petlund <apetlund@simula.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f201.google.com ([209.85.223.201]:58540 "EHLO
	mail-iw0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754687Ab0BLLTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 06:19:18 -0500
In-Reply-To: <4B73F30D.6040205@simula.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Last year, I'm pretty sure I was on record as thinking this is only a
marginally good idea, that would be better at the application layer.

Also that naming was a bit dicey.  Now the names are more descriptive,
but the "force" is a bit overkill.

How about?
   NET_TCP_FORCE_THIN_LINEAR_TIMEOUTS    -> NET_TCP_THIN_LINEAR_TIMEOUTS
   TCP_THIN_LT                           -> TCP_THIN_LINEAR_TIMEOUTS
   TCP_THIN_LT_RETRIES                   -> TCP_THIN_LINEAR_RETRIES
   tcp_force_thin_linear_timeouts        -> tcp_thin_linear_timeouts
   sysctl_tcp_force_thin_linear_timeouts -> sysctl_tcp_thin_linear_timeouts
   tp->thin_lt                           -> tp->thin_lto

The latter mostly traditional "to" for "timeout", as used most everywhere.


Andreas Petlund wrote:
> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
> index de7d1bf..a682479 100644
> --- a/net/ipv4/tcp_timer.c
> +++ b/net/ipv4/tcp_timer.c
> @@ -29,6 +29,7 @@ int sysctl_tcp_keepalive_intvl __read_mostly = TCP_KEEPALIVE_INTVL;
>  int sysctl_tcp_retries1 __read_mostly = TCP_RETR1;
>  int sysctl_tcp_retries2 __read_mostly = TCP_RETR2;
>  int sysctl_tcp_orphan_retries __read_mostly;
> +int sysctl_tcp_force_thin_linear_timeouts __read_mostly;
>  
Where is the sysctl initialized?


> +	if ((tp->thin_lt || sysctl_tcp_force_thin_linear_timeouts) &&
> +	    tcp_stream_is_thin(sk) && sk->sk_state == TCP_ESTABLISHED &&
> +	    icsk->icsk_retransmits <= TCP_THIN_LT_RETRIES) {

Just for efficiency, I'd reorder this
   +	if (sk->sk_state == TCP_ESTABLISHED &&
   +	    (tp->thin_lt || sysctl_tcp_force_thin_linear_timeouts) &&
   +	    tcp_stream_is_thin(sk) &&
   +	    icsk->icsk_retransmits <= TCP_THIN_LT_RETRIES) {

