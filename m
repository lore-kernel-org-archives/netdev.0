From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] tcp: prevent fetching dst twice in early demux
 code
Date: Mon, 23 Mar 2015 22:39:46 -0400 (EDT)
Message-ID: <20150323.223946.1369598595861439895.davem@davemloft.net>
References: <1427118542.25985.62.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150323141400.1568AA0CCC@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	edumazet@google.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: mkubecek@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150323141400.1568AA0CCC@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Kubecek <mkubecek@suse.cz>
Date: Mon, 23 Mar 2015 15:14:00 +0100 (CET)

> On s390x, gcc 4.8 compiles this part of tcp_v6_early_demux()
> 
>         struct dst_entry *dst = sk->sk_rx_dst;
> 
>         if (dst)
>                 dst = dst_check(dst, inet6_sk(sk)->rx_dst_cookie);
> 
> to code reading sk->sk_rx_dst twice, once for the test and once for
> the argument of ip6_dst_check() (dst_check() is inline). This allows
> ip6_dst_check() to be called with null first argument, causing a crash.
> 
> Protect sk->sk_rx_dst access by READ_ONCE() both in IPv4 and IPv6
> TCP early demux code.
> 
> Fixes: 41063e9dd119 ("ipv4: Early TCP socket demux.")
> Fixes: c7109986db3c ("ipv6: Early TCP socket demux")
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

Applied and queued up for -stable.
