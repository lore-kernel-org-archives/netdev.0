From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Commit 8ef874bfc7296fa206eea2ad1e8a426f576bf6f6 has broken ss
 command
Date: Wed, 04 Apr 2012 11:44:54 +0200
Message-ID: <1333532694.18626.563.camel@edumazet-glaptop>
References: <20120404090312.1B68C6AC03E@msa102.auone-net.jp>
	 <1333530463.18626.545.camel@edumazet-glaptop>
	 <20120404.052423.998527504342669775.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: slash@ac.auone-net.jp, netdev@vger.kernel.org, xemul@parallels.com,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120404.052423.998527504342669775.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-04-04 at 05:24 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 04 Apr 2012 11:07:43 +0200
> 
> > On Wed, 2012-04-04 at 18:03 +0900, Kusanagi Kouichi wrote:
> >> Since commit 8ef874bfc7296fa206eea2ad1e8a426f576bf6f6 ("sock_diag:
> >> Move the sock_ code to net/core/"), ss command from iproute package
> >> doesn't work if INET_DIAG is not enabled.
> >> 
> >> $ ss
> >> State       Recv-Q Send-Q                                             Local Address:Port                                                 Peer Address:Port
> >> TCPDIAG answers: Operation not supported
> >> --
> > 
> > Try to update your iproute2 package ?
> 
> Well, he doesn't INET_DIAG enabled in his kernel, so no matter what
> iproute2 version he uses it won't work :-)

iproute2 misc/ss.c has a fallback using /proc/net/tcp

Dont know when this broke.

I guess we should fix ss to cope INET_DIAG being disabled.

tcp_show_netlink() should return -1 instead of 0
