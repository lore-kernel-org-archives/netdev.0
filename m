From: David Miller <davem@davemloft.net>
Subject: Re: [Patch v3 2/3] ipv4: Namespaceify tcp_fastopen_key knob
Date: Wed, 20 Sep 2017 14:25:08 -0700 (PDT)
Message-ID: <20170920.142508.2226871042948634454.davem@davemloft.net>
References: <1505813896-12121-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
        <1505813896-12121-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, edumazet@google.com, weiwan@google.com,
        lucab@debian.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505813896-12121-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Tue, 19 Sep 2017 17:38:15 +0800

> @@ -128,6 +130,8 @@ struct netns_ipv4 {
>  	struct inet_timewait_death_row tcp_death_row;
>  	int sysctl_max_syn_backlog;
>  	int sysctl_tcp_fastopen;
> +	struct tcp_fastopen_context __rcu *tcp_fastopen_ctx;
> +	spinlock_t tcp_fastopen_ctx_lock;
>  
>  #ifdef CONFIG_NET_L3_MASTER_DEV
>  	int sysctl_udp_l3mdev_accept;

Where are you releasing this context during netns teardown?
I think this is a leak.
