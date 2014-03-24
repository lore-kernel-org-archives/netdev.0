From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 1/3] tcp: allow to enable repair mode for sockets in any
 state
Date: Tue, 25 Mar 2014 02:47:12 +0400
Message-ID: <5330B5F0.1090905@parallels.com>
References: <1395408781-8145-1-git-send-email-avagin@openvz.org> <1395408781-8145-2-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <criu@openvz.org>,
	<netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: Andrey Vagin <avagin@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:37854 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbaCXWrj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 18:47:39 -0400
In-Reply-To: <1395408781-8145-2-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> @@ -2375,7 +2378,7 @@ void tcp_sock_destruct(struct sock *sk)
>  static inline bool tcp_can_repair_sock(const struct sock *sk)
>  {
>  	return ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN) &&
> -		((1 << sk->sk_state) & (TCPF_CLOSE | TCPF_ESTABLISHED));
> +		(sk->sk_state != TCP_LISTEN);

This set only covers states that may happen after ESTABLISHED, so
I would still exclude others (e.g. syn-sent) from the white list.

>  }
>  
>  static int tcp_repair_options_est(struct tcp_sock *tp,
> 

Thanks,
Pavel
