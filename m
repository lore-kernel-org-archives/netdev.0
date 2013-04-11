From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND] tcp: incoming connections might use wrong route
 under synflood
Date: Thu, 11 Apr 2013 16:02:31 -0400 (EDT)
Message-ID: <20130411.160231.1367130064866607872.davem@davemloft.net>
References: <20130411225507.427b369046e53d03222b8fd3@highloadlab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: dp@highloadlab.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130411225507.427b369046e53d03222b8fd3@highloadlab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitry Popov <dp@highloadlab.com>
Date: Thu, 11 Apr 2013 22:55:07 +0400

> There is a bug in cookie_v4_check (net/ipv4/syncookies.c):
> 	flowi4_init_output(&fl4, 0, sk->sk_mark, RT_CONN_FLAGS(sk),
> 			   RT_SCOPE_UNIVERSE, IPPROTO_TCP,
> 			   inet_sk_flowi_flags(sk),
> 			   (opt && opt->srr) ? opt->faddr : ireq->rmt_addr,
> 			   ireq->loc_addr, th->source, th->dest);
> 
> Here we do not respect sk->sk_bound_dev_if, therefore wrong dst_entry may be
> taken. This dst_entry is used by new socket (get_cookie_sock -> 
> tcp_v4_syn_recv_sock), so its packets may take the wrong path.
> 
> Signed-off-by: Dmitry Popov <dp@highloadlab.com>

Applied.
