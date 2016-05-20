From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ip6_gre: Fix MTU setting for ip6gretap
Date: Fri, 20 May 2016 10:47:48 -0700 (PDT)
Message-ID: <20160520.104748.14485785092408851.davem@davemloft.net>
References: <1463565952-8781-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463565952-8781-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Wed, 18 May 2016 18:05:51 +0800

> When creat an ip6gretap interface with an unreachable route,
> the MTU is about 14 bytes larger than what was needed.
> 
> If the remote address is reachable:
> ping6 2001:0:130::1 -c 2
> PING 2001:0:130::1(2001:0:130::1) 56 data bytes
> 64 bytes from 2001:0:130::1: icmp_seq=1 ttl=64 time=1.46 ms
> 64 bytes from 2001:0:130::1: icmp_seq=2 ttl=64 time=81.1 ms
> 
> --- 2001:0:130::1 ping statistics ---
> 2 packets transmitted, 2 received, 0% packet loss, time 1001ms
> rtt min/avg/max/mdev = 1.465/41.316/81.167/39.851 ms
> 
> ip link add ip6gretap1 type ip6gretap\
>  local 2001:0:130::2 remote 2001:0:130::1
> ip link show ip6gretap1
> 11: ip6gretap1@NONE: <BROADCAST,MULTICAST> mtu 1434 ...
>     link/ether c2:f3:f8:c1:2c:bf brd ff:ff:ff:ff:ff:ff
> 
> The MTU value 1434 is right. But if we delete the direct route:
> ip -6 route del 2001:0:130::/64
> ping6 2001:0:130::1 -c 2
> connect: Network is unreachable
> ip link add ip6gretap1 type ip6gretap\
>  local 2001:0:130::2 remote 2001:0:130::1
> ip link show ip6gretap1
> 12: ip6gretap1@NONE: <BROADCAST,MULTICAST> mtu 1448 ...
>     link/ether 7e:e1:d2:c4:06:5e brd ff:ff:ff:ff:ff:ff
> 
> Now, the MTU value 1448 is larger than what was needed.
> 
> This patch fix the issue in this situation.
> 
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

It's great that you have provided precise examples of how to reproduce
the problem.

But you need to explain in your commit message how your fix works.
Why does simply checking the device type and subtracting the ethernet
header length work here?  What is the full context for your fix and
why does it work?
