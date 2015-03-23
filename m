From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] tcp: prevent fetching dst twice in early demux
 code
Date: Mon, 23 Mar 2015 07:39:24 -0700
Message-ID: <1427121564.25985.69.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1427118542.25985.62.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150323141400.1568AA0CCC@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150323141400.1568AA0CCC@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-03-23 at 15:14 +0100, Michal Kubecek wrote:
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
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks Michal
