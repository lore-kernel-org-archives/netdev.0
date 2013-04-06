From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: IPv6 TCP-Connections resetting
Date: Sat, 06 Apr 2013 10:54:39 -0700
Message-ID: <1365270879.3887.4.camel@edumazet-glaptop>
References: <20130405174828.310a02c3@trediske.ws.office.manitu.net>
	 <20130406043534.GC30194@order.stressinduktion.org>
	 <1460015.zN3jPXiAbD@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Tetja Rediske <tetja@tetja.de>, djduanjiong@gmail.com,
	netdev@vger.kernel.org, steffen.klassert@secunet.com,
	Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:45065 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751070Ab3DFRyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Apr 2013 13:54:43 -0400
Received: by mail-pa0-f42.google.com with SMTP id kq13so2537236pab.29
        for <netdev@vger.kernel.org>; Sat, 06 Apr 2013 10:54:42 -0700 (PDT)
In-Reply-To: <1460015.zN3jPXiAbD@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-04-06 at 11:14 +0200, Christoph Paasch wrote:
> Hello,
> 
> On Saturday 06 April 2013 06:35:34 Hannes Frederic Sowa wrote:
> > > [1.] One line summary of the problem:
> > > 
> > > IPv6 TCP-Connections resetting
> > > 
> > > [2.] Full description of the problem/report:
> > > 
> > > In the last weeks we updated some of our systems to a 3.8.4 Kernel.
> > > Since then sometimes we can't connect to services running IPv6,
> > > Apache and Openssh tested.
> > > 
> > > We got this on different machines with x86 and x86_64 Kernels. On
> > > x86_64 it is more random, but on x86 i can reproduce it permanently
> > > (Just opening any TCP Connection 1st time or after some short delay).
> > > Connecting quick after the reset again will work as expected. It will
> > > also work, if you keep another connection open.
> > > 
> > > Before I got to the Kernel, I just kept an strace on an userspace
> > > process, but it did not notice the connection attempt. After this I
> > > monitored the connection with tcpdump, but nothing unusual.
> > > 
> > > Then I did a rollback to the older Kernel and it worked as expected.
> > > 
> > > I tracked it down with 'git bisect' to commit:
> > >   093d04d42fa094f6740bb188f0ad0c215ff61e2c
> > > 
> > > I also tested latest git state available.
> > > 
> > > [3.] Keywords (i.e., modules, networking, kernel):
> > > 
> > > networking, IPv6
> > > 
> > > [4.] Kernel information
> > > 
> > > [4.1.] Kernel version (from /proc/version):
> > >   since commit: 093d04d42fa094f6740bb188f0ad0c215ff61e2c
> > > 
> > > [4.2.] Kernel .config file:
> > > [5.] Most recent kernel version which did not have the bug:
> > > 
> > > none
> > > 
> > > [6.] Output of Oops.. message (if applicable) with symbolic information
> > > 
> > >      resolved (see Documentation/oops-tracing.txt)
> > > 
> > > [7.] A small shell script or example program which triggers the
> > > 
> > >      problem (if possible)
> > > 
> > > [8.] Environment
> > > [8.1.] Software (add the output of the ver_linux script here)
> > > 
> > > Different systems, mostly reproduced on this one:
> > > 
> > > Linux dns03.tetja.de 3.9.0-rc5+ #10 SMP Fri Apr 5 16:55:54 CEST 2013
> > > i686 AMD Athlon(tm) 64 X2 Dual Core Processor 5600+ AuthenticAMD
> > > GNU/Linux
> > > 
> > > Gnu C                  4.4.5
> > > Gnu make               3.82
> > > binutils               2.22
> > > util-linux             2.22.2
> > > mount                  debug
> > > module-init-tools      12
> > > e2fsprogs              1.42
> > > jfsutils               1.1.15
> > > reiserfsprogs          3.6.21
> > > xfsprogs               3.1.10
> > > Linux C Library        2.15
> > > Dynamic linker (ldd)   2.15
> > > Procps                 3.3.4
> > > Net-tools              1.60_p20120127084908
> > > Kbd                    1.15.3wip
> > > Sh-utils               8.20
> > > Modules Loaded
> > > 
> > > Connections looking like this on booth sites:
> > > 
> > > 11:52:04.634315 IP6 2a00:1828:0:1::10.51808 >
> > > 2a00:1828:1000:1102::2.80: Flags [S], seq 103067898, win 5760, options
> > > [mss 1440,sackOK,TS val 232579708 ecr 0,nop,wscale 7], length 0
> > > 
> > > 11:52:04.634354 IP6 2a00:1828:1000:1102::2.80 >
> > > 2a00:1828:0:1::10.51808: Flags [S.], seq 3352491415, ack 103067899, win
> > > 14280, options [mss 1440,sackOK,TS val 174797959 ecr
> > > 232579708,nop,wscale 7], length 0
> > > 
> > > 11:52:04.634656 IP6 fe80::92e2:baff:fe00:c120 > 2a00:1828:1000:1102::2:
> > > ICMP6, redirect, 2a00:1828:0:1::10 to 2a00:1828:0:1::10, length 136
> > > 
> > > 11:52:04.634715 IP6 2a00:1828:0:1::10.51808 >
> > > 2a00:1828:1000:1102::2.80: Flags [.], ack 1, win 45, options
> > > [nop,nop,TS val 232579708 ecr 174797959], length 0
> > > 
> > > 11:52:04.634726 IP6 2a00:1828:1000:1102::2.80 >
> > > 2a00:1828:0:1::10.51808: Flags [R], seq 3352491416, win 0, length 0
> > > 
> > > 11:52:04.635027 IP6 2a00:1828:0:1::10.51808 >
> > > 2a00:1828:1000:1102::2.80: Flags [P.], seq 1:359, ack 1, win 45,
> > > options [nop,nop,TS val 232579708 ecr 174797959], length 358
> > > 
> > > 11:52:04.635037 IP6 2a00:1828:1000:1102::2.80 >
> > > 2a00:1828:0:1::10.51808: Flags [R], seq 3352491416, win 0, length 0
> > > 
> > > 11:52:04.635071 IP6 fe80::92e2:baff:fe00:c120 > 2a00:1828:1000:1102::2:
> > > ICMP6, redirect, 2a00:1828:0:1::10 to 2a00:1828:0:1::10, length 112
> > > 
> > > 11:52:04.635246 IP6 fe80::92e2:baff:fe00:c120 > 2a00:1828:1000:1102::2:
> > > ICMP6, redirect, 2a00:1828:0:1::10 to 2a00:1828:0:1::10, length 112
> 
> May it simply be a missing "goto out" in tcp_v6_err (see below patch) ?
> 
> Cheers,
> Christoph
> 
> --------
> 
> From: Christoph Paasch <christoph.paasch@uclouvain.be>
> Date: Sat, 6 Apr 2013 10:21:01 +0200
> Subject: [PATCH] ipv6/tcp: Stop processing ICMPv6 redirect messages
> 
> Upon reception of an ICMPv6 Redirect message, we should not continue
> inside tcp_v6_err. Otherwise, an error will be reported or request-socks
> will be closed.
> 
> Adds also some parantheses to respect codingstyle guidelines.
> 
> Reported-by: Tetja Rediske <tetja@tetja.de>
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> ---
>  net/ipv6/tcp_ipv6.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 1033d2b..24434c5 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -386,6 +386,7 @@ static void tcp_v6_err(struct sk_buff *skb, struct 
> inet6_skb_parm *opt,
>  
>  		if (dst)
>  			dst->ops->redirect(dst, sk, skb);
> +		goto out;
>  	}
>  

OK, it seems bug was added in commit
ec18d9a2691d69cd14b48f9b919fddcef28b7f5c
(ipv6: Add redirect support to all protocol icmp error handlers.)

Not sure why Tetja Rediske  bisected to
093d04d42fa094f6740bb188f0ad0c215ff61e2c

Could you send a patch with this single line change (no cleanup), and
a more detailed changelog, once the bug origin is clearly identified ?

Thanks !
