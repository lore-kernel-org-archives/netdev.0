From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: (usagi-users 02296) IPv6 duplicate address bugfix
Date: Sun, 30 Mar 2003 22:08:29 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030330.220829.129728506.yoshfuji@linux-ipv6.org>
References: <20030330122705.GA18283@ferrara.linux.it>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, ds6-devel@deepspace6.net
Return-path: <netdev-bounce@oss.sgi.com>
To: usagi-users@linux-ipv6.org, pioppo@ferrara.linux.it
In-Reply-To: <20030330122705.GA18283@ferrara.linux.it>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030330122705.GA18283@ferrara.linux.it> (at Sun, 30 Mar 2003 14:27:05 +0200), Simone Piunno <pioppo@ferrara.linux.it> says:

> When adding an IPv6 address to a given interface, I'm allowed to
> add that address multiple time, e.g.:
> 
> [root@abulafia root]# ip addr add 3ffe:4242:4242::1 dev eth0
> [root@abulafia root]# ip addr add 3ffe:4242:4242::1 dev eth0
> [root@abulafia root]# ip addr add 3ffe:4242:4242::1 dev eth0
> [root@abulafia root]# ip addr show dev eth0
> 2: eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
>     link/ether 00:48:54:1b:25:30 brd ff:ff:ff:ff:ff:ff
>     inet6 3ffe:4242:4242::1/128 scope global 
>     inet6 3ffe:4242:4242::1/128 scope global 
>     inet6 3ffe:4242:4242::1/128 scope global 
>     inet6 fe80::248:54ff:fe1b:2530/10 scope link
> 
> Apparently, this is not a stability problem, because I'm allowed to 
> delete 3 times that address before receving a "not found" error,
> but there's no reason to allow multiple instances of the same address 
> on the same interface, so this is a bug nonetheless.
> 
> Bug is confirmed on:
>   - 2.4.20
>   - 2.5.66
>   - latest -usagi

usagi code does not act like that.

In my environment,

# ip addr add 3ffe:4242:4242::1 dev eth0
# ip addr add 3ffe:4242:4242::1 dev eth0
RTNETLINK answers: No buffer space available
# ip addr add 3ffe:4242:4242::1 dev eth0
RTNETLINK answers: No buffer space available

And, patch does not seem optimal. I'd take a look at very soon.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
