From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: 2.6.6: IPv6 initialisation bug
Date: Tue, 29 Jun 2004 02:06:27 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040629.020627.76560474.yoshfuji@linux-ipv6.org>
References: <20040628010200.A15067@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: rmk+lkml@arm.linux.org.uk
In-Reply-To: <20040628010200.A15067@flint.arm.linux.org.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040628010200.A15067@flint.arm.linux.org.uk> (at Mon, 28 Jun 2004 01:02:01 +0100), Russell King <rmk+lkml@arm.linux.org.uk> says:

> Ok, I've just tried 2.6.7 out on my root-NFS'd firewall with IPv6 built
> in, and it doesn't work because of the problem I described below.
:
> What's the solution?

Bring lo up before bring others up.
What does prevent you from doing this?
(Do we need some bits to do this automatically?)


> Is there a good reason why IPv6 uses the loopback device for local
> routes?

IPv6 creates kernel routes for local addresses on lo to receive
packets for local address.

Well, someone probably wants to have
static local routes on ethX + temprary (cache) local routes on lo
(as IPv4 does; correct me if I'm wrong.)

But this won't work because IPv6 does DAD when we make some interface up.
We need lo anyway.

--yoshfuji
