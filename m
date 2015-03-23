From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net] tcp: prevent fetching dst twice in early demux code
Date: Mon, 23 Mar 2015 15:12:50 +0100
Message-ID: <20150323141250.GA4673@unicorn.suse.cz>
References: <20150323082718.265EDA0BE9@unicorn.suse.cz>
 <1427118542.25985.62.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1427118542.25985.62.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 23, 2015 at 06:49:02AM -0700, Eric Dumazet wrote:
> On Mon, 2015-03-23 at 09:27 +0100, Michal Kubecek wrote:
> > On s390x, gcc 4.8 compiles this part of tcp_v6_early_demux()
> > 
> >         struct dst_entry *dst = sk->sk_rx_dst;
> > 
> >         if (dst)
> >                 dst = dst_check(dst, inet6_sk(sk)->rx_dst_cookie);
> > 
> > to code reading sk->sk_rx_dst twice, once for the test and once for
> > the argument of ip6_dst_check() (dst_check() is inline). This allows
> > ip6_dst_check() to be called with null first argument, causing a crash.
> 
> Good catch, (or would I say, strange compiler ? ;) )

I was also surprised when I saw the code, considering that the code
saved registers %r6 through %r13 and didn't use most of them.

> Please use READ_ONCE().  Only stable ports will need ACCESS_ONCE()

I'll send v2 with READ_ONCE() in a moment.

> Also, this probably points a problem on this arch, because its looks
> different cpu are handling TCP traffic for the same TCP flow.

Good point, this will be worth looking into.

                                                        Michal Kubecek
