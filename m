From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 2/3] ipv6: per netns fib6 walkers
Date: Mon, 7 Mar 2016 16:26:01 -0800
Message-ID: <CAM_iQpUxHX71GRmnmcvXpOX4P4mzJXpoYmcYhcZi2CXxEK4XFQ@mail.gmail.com>
References: <cover.1457085016.git.mkubecek@suse.cz>
	<6df8e224d6337b658a097ac87e72e1467cddf13d.1457085016.git.mkubecek@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Martin KaFai Lau <kafai@fb.com>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6df8e224d6337b658a097ac87e72e1467cddf13d.1457085016.git.mkubecek@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 4, 2016 at 2:59 AM, Michal Kubecek <mkubecek@suse.cz> wrote:
>  static void ipv6_route_seq_setup_walk(struct ipv6_route_iter *iter)
>  {
> +#ifdef CONFIG_NET_NS
> +       struct net *net = iter->p.net;
> +#else
> +       struct net *net = &init_net;
> +#endif
> +

You should pass the struct net pointer to ipv6_route_seq_setup_walk()
instead of reading it by yourself.

I don't find anyone actually using iter->p, it probably can be just removed.
