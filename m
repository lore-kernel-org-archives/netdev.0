From: David Miller <davem@davemloft.net>
Subject: Re: [Patch v3 1/3] ipv4: Namespaceify tcp_fastopen knob
Date: Wed, 20 Sep 2017 14:22:27 -0700 (PDT)
Message-ID: <20170920.142227.65942571438912956.davem@davemloft.net>
References: <1505813896-12121-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, edumazet@google.com, weiwan@google.com,
        lucab@debian.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505813896-12121-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Tue, 19 Sep 2017 17:38:14 +0800

> -		if ((sysctl_tcp_fastopen & TFO_SERVER_WO_SOCKOPT1) &&
> -		    (sysctl_tcp_fastopen & TFO_SERVER_ENABLE) &&
> +		tcp_fastopen =  sock_net(sk)->ipv4.sysctl_tcp_fastopen;
                              ^^

Please change that to one space.

And also please provide an appropriate "[PATCH vX 0/3] " header
posting when you respin this series.

> @@ -282,18 +280,19 @@ struct sock *tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
>  	struct tcp_fastopen_cookie valid_foc = { .len = -1 };
>  	bool syn_data = TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq + 1;
>  	struct sock *child;
> +	int tcp_fastopen = sock_net(sk)->ipv4.sysctl_tcp_fastopen;

Please order local variables from longest to shortest line (aka. reverse
christmas tree format).
